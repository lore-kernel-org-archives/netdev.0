From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] net: fec: use module_platform_driver
Date: Tue, 24 Jan 2012 00:44:50 -0200
Message-ID: <1327373090-22004-1-git-send-email-festevam@gmail.com>
Cc: davem@davemloft.net, kernel@pengutronix.de,
	Fabio Estevam <fabio.estevam@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:36671 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093Ab2AXCpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 21:45:05 -0500
Received: by ghrr11 with SMTP id r11so608154ghr.19
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2012 18:45:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using module_platform_driver can make the code smaller.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec.c |   17 +----------------
 1 files changed, 1 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 7b25e9c..e5885cc 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1739,21 +1739,6 @@ static struct platform_driver fec_driver = {
 	.remove	= __devexit_p(fec_drv_remove),
 };
 
-static int __init
-fec_enet_module_init(void)
-{
-	printk(KERN_INFO "FEC Ethernet Driver\n");
-
-	return platform_driver_register(&fec_driver);
-}
-
-static void __exit
-fec_enet_cleanup(void)
-{
-	platform_driver_unregister(&fec_driver);
-}
-
-module_exit(fec_enet_cleanup);
-module_init(fec_enet_module_init);
+module_platform_driver(fec_driver);
 
 MODULE_LICENSE("GPL");
-- 
1.7.1
