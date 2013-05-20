From: Peter Huewe <peterhuewe@gmx.de>
Subject: [PATCH] net/wireless/ti/wlcore/spi: Use module_spi_driver to register driver
Date: Mon, 20 May 2013 21:52:40 +0200
Message-ID: <1369079560-6101-1-git-send-email-peterhuewe@gmx.de>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Felipe Balbi <balbi@ti.com>, Ido Yariv <ido@wizery.com>,
	Arik Nemtsov <arik@wizery.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Huewe <peterhuewe@gmx.de>
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing some boilerplate by using module_spi_driver instead of calling
register and unregister in the otherwise empty init/exit functions

Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
---
 drivers/net/wireless/ti/wlcore/spi.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/spi.c b/drivers/net/wireless/ti/wlcore/spi.c
index e264478..1b0cd98 100644
--- a/drivers/net/wireless/ti/wlcore/spi.c
+++ b/drivers/net/wireless/ti/wlcore/spi.c
@@ -434,19 +434,7 @@ static struct spi_driver wl1271_spi_driver = {
 	.remove		= wl1271_remove,
 };
 
-static int __init wl1271_init(void)
-{
-	return spi_register_driver(&wl1271_spi_driver);
-}
-
-static void __exit wl1271_exit(void)
-{
-	spi_unregister_driver(&wl1271_spi_driver);
-}
-
-module_init(wl1271_init);
-module_exit(wl1271_exit);
-
+module_spi_driver(wl1271_spi_driver);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Luciano Coelho <coelho@ti.com>");
 MODULE_AUTHOR("Juuso Oikarinen <juuso.oikarinen@nokia.com>");
-- 
1.8.1.5
