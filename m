From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: ethernet: xilinx: Convert xilinx_axienet to module_platform_driver
Date: Fri, 17 Feb 2012 16:35:37 +0100
Message-ID: <1329492937-23165-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: Ariane Keller <ariane.keller@tik.ee.ethz.ch>,
	Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:56768 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751588Ab2BQPpa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Feb 2012 10:45:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow commit db62f684. Convert the driver to use the
module_platform_driver() macro which makes the code a bit smaller and
simpler.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |   13 +------------
 1 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index a7cf004..2fcbeba 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1662,18 +1662,7 @@ static struct platform_driver axienet_of_driver = {
 	},
 };
 
-static int __init axienet_init(void)
-{
-	return platform_driver_register(&axienet_of_driver);
-}
-
-static void __exit axienet_exit(void)
-{
-	platform_driver_unregister(&axienet_of_driver);
-}
-
-module_init(axienet_init);
-module_exit(axienet_exit);
+module_platform_driver(axienet_of_driver);
 
 MODULE_DESCRIPTION("Xilinx Axi Ethernet driver");
 MODULE_AUTHOR("Xilinx");
-- 
1.7.5.4
