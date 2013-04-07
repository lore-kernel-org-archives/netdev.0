From: Lars-Peter Clausen <lars@metafoo.de>
Subject: [PATCH 1/2] net: ks8851: Use module_spi_driver
Date: Sun,  7 Apr 2013 11:33:03 +0200
Message-ID: <1365327184-22956-1-git-send-email-lars@metafoo.de>
Cc: Ben Dooks <ben-linux@fluff.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Lars-Peter Clausen <lars@metafoo.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By using module_spi_driver we can eliminate a few lines of boilerplate code.

Signed-off-by: Lars-Peter Clausen <lars@metafoo.de>
---
 drivers/net/ethernet/micrel/ks8851.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 8fb4812..84ca876 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1538,19 +1538,7 @@ static struct spi_driver ks8851_driver = {
 	.suspend = ks8851_suspend,
 	.resume = ks8851_resume,
 };
-
-static int __init ks8851_init(void)
-{
-	return spi_register_driver(&ks8851_driver);
-}
-
-static void __exit ks8851_exit(void)
-{
-	spi_unregister_driver(&ks8851_driver);
-}
-
-module_init(ks8851_init);
-module_exit(ks8851_exit);
+module_spi_driver(ks8851_driver);
 
 MODULE_DESCRIPTION("KS8851 Network driver");
 MODULE_AUTHOR("Ben Dooks <ben@simtec.co.uk>");
-- 
1.8.0
