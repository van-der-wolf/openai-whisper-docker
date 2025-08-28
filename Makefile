build:
	docker build -t openai-whisper .

from-video:
	@echo "Processing video files from .input directory..."
	@find .input -name "*.mp4" -o -name "*.mov" -o -name "*.avi" -o -name "*.mkv" -o -name "*.webm" -o -name "*.m4v" | while read -r video; do \
		if [ -f "$$video" ]; then \
			echo "Processing $$video..."; \
			basename=$$(basename "$$video" | sed 's/\.[^.]*$$//'); \
			if [ ! -f ".input/$$basename.mp3" ]; then \
				echo "Extracting audio from $$video..."; \
				ffmpeg -i "$$video" -vn -acodec mp3 -ab 128k ".input/$$basename.mp3" -y; \
			else \
				echo "Using cached audio file .input/$$basename.mp3"; \
			fi; \
			echo "Transcribing audio..."; \
			echo "Running: docker run --rm -v $${PWD}/.input:/app/input -v $${PWD}/.output:/app/output -v $${PWD}/models:/root/.cache/whisper openai-whisper whisper \"/app/input/$$basename.mp3\" --model turbo --output_dir /app/output --output_format txt"; \
			docker run --rm -v $${PWD}/.input:/app/input -v $${PWD}/.output:/app/output -v $${PWD}/models:/root/.cache/whisper openai-whisper whisper "/app/input/$$basename.mp3" --model turbo --output_dir /app/output --output_format txt; \
		fi; \
	done
