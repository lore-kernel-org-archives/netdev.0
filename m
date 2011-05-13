From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Subject: [RFC/PATCH 03/13] net: wl12xx: remove some unnecessary prints
Date: Sat, 14 May 2011 00:26:20 +0300
Message-ID: <1305321990-22041-4-git-send-email-balbi@ti.com>
References: <1305321990-22041-1-git-send-email-balbi@ti.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
To: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1305321990-22041-1-git-send-email-balbi-l0cyMroinI0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Those have little value. Remove those to make
the driver less noisy.

Signed-off-by: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
---
 drivers/net/wireless/wl12xx/sdio.c |   15 +--------------
 1 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/sdio.c b/drivers/net/wireless/wl12xx/sdio.c
index fe775d3..0832b80 100644
--- a/drivers/net/wireless/wl12xx/sdio.c
+++ b/drivers/net/wireless/wl12xx/sdio.c
@@ -287,8 +287,6 @@ static int __devinit wl1271_probe(struct sdio_func *func,
 	/* Tell PM core that we don't need the card to be powered now */
 	pm_runtime_put_noidle(&func->dev);
 
-	wl1271_notice("initialized");
-
 	return 0;
 
 err3:
@@ -347,23 +345,12 @@ static struct sdio_driver wl1271_sdio_driver = {
 
 static int __init wl1271_init(void)
 {
-	int ret;
-
-	ret = sdio_register_driver(&wl1271_sdio_driver);
-	if (ret < 0) {
-		wl1271_error("failed to register sdio driver: %d", ret);
-		goto out;
-	}
-
-out:
-	return ret;
+	return sdio_register_driver(&wl1271_sdio_driver);
 }
 
 static void __exit wl1271_exit(void)
 {
 	sdio_unregister_driver(&wl1271_sdio_driver);
