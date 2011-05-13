From: Felipe Balbi <balbi@ti.com>
Subject: [RFC/PATCH 06/13] net: wl12xx: remove unnecessary prints
Date: Sat, 14 May 2011 00:26:23 +0300
Message-ID: <1305321990-22041-7-git-send-email-balbi@ti.com>
References: <1305321990-22041-1-git-send-email-balbi@ti.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Felipe Balbi <balbi@ti.com>
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305321990-22041-1-git-send-email-balbi@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Those have little value. Remove those to
make the driver less noisy.

Signed-off-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/wireless/wl12xx/spi.c |   15 +--------------
 1 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/spi.c b/drivers/net/wireless/wl12xx/spi.c
index ffc745b..382b79d 100644
--- a/drivers/net/wireless/wl12xx/spi.c
+++ b/drivers/net/wireless/wl12xx/spi.c
@@ -426,8 +426,6 @@ static int __devinit wl1271_probe(struct spi_device *spi)
 	if (ret)
 		goto out_irq;
 
-	wl1271_notice("initialized");
-
 	return 0;
 
  out_irq:
@@ -464,23 +462,12 @@ static struct spi_driver wl1271_spi_driver = {
 
 static int __init wl1271_init(void)
 {
-	int ret;
-
-	ret = spi_register_driver(&wl1271_spi_driver);
-	if (ret < 0) {
-		wl1271_error("failed to register spi driver: %d", ret);
-		goto out;
-	}
-
-out:
-	return ret;
+	return spi_register_driver(&wl1271_spi_driver);
 }
 
 static void __exit wl1271_exit(void)
 {
 	spi_unregister_driver(&wl1271_spi_driver);
-
-	wl1271_notice("unloaded");
 }
 
 module_init(wl1271_init);
-- 
1.7.4.1.343.ga91df
