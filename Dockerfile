FROM python:3.11-slim

WORKDIR /app

# --- Python deps ---
COPY backend/requirements.txt backend/requirements.txt
RUN pip install --no-cache-dir -r backend/requirements.txt gunicorn

# --- Install Node.js 20 (stable) ---
RUN apt-get update && apt-get install -y curl \
  && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Frontend deps & build ---
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Railway provides PORT, default fallback
ENV PORT=8080
EXPOSE 8080

# (اختياري) تهيئة الداتابيز لو عندك init
# CMD ["sh", "-c", "python backend/database/init_db.py && gunicorn -b 0.0.0.0:${PORT} backend.app:app"]

CMD ["sh", "-c", "gunicorn -b 0.0.0.0:${PORT} backend.app:app"]