From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 39/39] mv643xx_eth: update driver version and author fields
Date: Tue,  3 Jun 2008 13:02:54 +0200
Message-ID: <1212490974-23719-40-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48750 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754327AbYFCMAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:45 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 4b6c810..cd85222 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -47,7 +47,7 @@
 #include <linux/mv643xx_eth.h>
 
 static char mv643xx_eth_driver_name[] = "mv643xx_eth";
-static char mv643xx_eth_driver_version[] = "1.0";
+static char mv643xx_eth_driver_version[] = "1.1";
 
 #define MV643XX_ETH_CHECKSUM_OFFLOAD_TX
 #define MV643XX_ETH_NAPI
@@ -2551,8 +2551,8 @@ static void __exit mv643xx_eth_cleanup_module(void)
 }
 module_exit(mv643xx_eth_cleanup_module);
 
-MODULE_AUTHOR("Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, Manish Lachwani "
-	      "and Dale Farnsworth");
+MODULE_AUTHOR("Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, "
+	      "Manish Lachwani, Dale Farnsworth and Lennert Buytenhek");
 MODULE_DESCRIPTION("Ethernet driver for Marvell MV643XX");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("platform:" MV643XX_ETH_SHARED_NAME);
-- 
1.5.3.4

