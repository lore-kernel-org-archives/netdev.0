From: Sachin Kamat <sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/2] net: wireless: wl1251: Use module_spi_driver macro
Date: Wed, 29 May 2013 15:48:22 +0530
Message-ID: <1369822703-27769-1-git-send-email-sachin.kamat@linaro.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, coelho-l0cyMroinI0@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

module_spi_driver() eliminates some boiler plate and makes code
simpler.

Signed-off-by: Sachin Kamat <sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/ti/wl1251/spi.c |   24 +-----------------------
 1 file changed, 1 insertion(+), 23 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/spi.c b/drivers/net/wireless/ti/wl1251/spi.c
index 4c67c2f..dfd0877 100644
--- a/drivers/net/wireless/ti/wl1251/spi.c
+++ b/drivers/net/wireless/ti/wl1251/spi.c
@@ -329,29 +329,7 @@ static struct spi_driver wl1251_spi_driver = {
 	.remove		= wl1251_spi_remove,
 };
 
-static int __init wl1251_spi_init(void)
-{
-	int ret;
-
-	ret = spi_register_driver(&wl1251_spi_driver);
-	if (ret < 0) {
-		wl1251_error("failed to register spi driver: %d", ret);
-		goto out;
-	}
-
-out:
-	return ret;
-}
-
-static void __exit wl1251_spi_exit(void)
-{
-	spi_unregister_driver(&wl1251_spi_driver);
-
-	wl1251_notice("unloaded");
-}
