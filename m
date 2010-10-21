From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 10/10] can: at91_can: add KBUILD_MODNAME to bittiming constant
Date: Thu, 21 Oct 2010 13:01:22 +0200
Message-ID: <1287658882-26914-11-git-send-email-mkl@pengutronix.de>
References: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: socketcan-core@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34933 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757271Ab0JULB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:01:28 -0400
In-Reply-To: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While there replace all usage of self defined DRV_NAME by KBUILD_MODNAME.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/at91_can.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 7149a86..cee98fa 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -40,7 +40,6 @@
 
 #include <mach/board.h>
 
-#define DRV_NAME		"at91_can"
 #define AT91_NAPI_WEIGHT	12
 
 /*
@@ -172,6 +171,7 @@ struct at91_priv {
 };
 
 static struct can_bittiming_const at91_bittiming_const = {
+	.name		= KBUILD_MODNAME,
 	.tseg1_min	= 4,
 	.tseg1_max	= 16,
 	.tseg2_min	= 2,
@@ -1148,7 +1148,7 @@ static struct platform_driver at91_can_driver = {
 	.probe		= at91_can_probe,
 	.remove		= __devexit_p(at91_can_remove),
 	.driver		= {
-		.name	= DRV_NAME,
+		.name	= KBUILD_MODNAME,
 		.owner	= THIS_MODULE,
 	},
 };
@@ -1168,4 +1168,4 @@ module_exit(at91_can_module_exit);
 
 MODULE_AUTHOR("Marc Kleine-Budde <mkl@pengutronix.de>");
 MODULE_LICENSE("GPL v2");
-MODULE_DESCRIPTION(DRV_NAME " CAN netdevice driver");
+MODULE_DESCRIPTION(KBUILD_MODNAME " CAN netdevice driver");
-- 
1.7.0.4

