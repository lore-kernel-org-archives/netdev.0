From: Sachin Kamat <sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/2] net: wireless: wl1251: Fix commenting style
Date: Wed, 29 May 2013 15:48:23 +0530
Message-ID: <1369822703-27769-2-git-send-email-sachin.kamat@linaro.org>
References: <1369822703-27769-1-git-send-email-sachin.kamat@linaro.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, coelho-l0cyMroinI0@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1369822703-27769-1-git-send-email-sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Make the commenting style consistent with networking block comment
style as suggested by checkpatch.

Signed-off-by: Sachin Kamat <sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/ti/wl1251/spi.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/spi.c b/drivers/net/wireless/ti/wl1251/spi.c
index dfd0877..c7dc6fe 100644
--- a/drivers/net/wireless/ti/wl1251/spi.c
+++ b/drivers/net/wireless/ti/wl1251/spi.c
@@ -93,8 +93,7 @@ static void wl1251_spi_wake(struct wl1251 *wl)
 	memset(&t, 0, sizeof(t));
 	spi_message_init(&m);
 
-	/*
-	 * Set WSPI_INIT_COMMAND
+	/* Set WSPI_INIT_COMMAND
 	 * the data is being send from the MSB to LSB
 	 */
 	cmd[2] = 0xff;
@@ -262,7 +261,8 @@ static int wl1251_spi_probe(struct spi_device *spi)
 	wl->if_ops = &wl1251_spi_ops;
 
 	/* This is the only SPI value that we need to set here, the rest
-	 * comes from the board-peripherals file */
+	 * comes from the board-peripherals file
+	 */
 	spi->bits_per_word = 32;
 
 	ret = spi_setup(spi);
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
