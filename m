From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 3/3] gianfar: delete orphaned version strings and dead macros
Date: Sun, 18 Mar 2012 12:56:27 -0400
Message-ID: <1332089787-24086-4-git-send-email-paul.gortmaker@windriver.com>
References: <1332089787-24086-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net, eric.dumazet@gmail.com, therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43544 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755963Ab2CRQ4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 12:56:55 -0400
In-Reply-To: <1332089787-24086-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There were two version strings, and neither one was being used.
Also in the same proximity were some unused #define that were
left over from the past.  Delete them all.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/freescale/gianfar.c |    3 ---
 drivers/net/ethernet/freescale/gianfar.h |    3 ---
 2 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index a4c934b..6e66cc3 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -104,10 +104,7 @@
 #include "fsl_pq_mdio.h"
 
 #define TX_TIMEOUT      (1*HZ)
-#undef BRIEF_GFAR_ERRORS
-#undef VERBOSE_GFAR_ERRORS
 
-const char gfar_driver_name[] = "Gianfar Ethernet";
 const char gfar_driver_version[] = "1.3";
 
 static int gfar_enet_open(struct net_device *dev);
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 4fe0f34..fc2488a 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -78,11 +78,8 @@ struct ethtool_rx_list {
 #define INCREMENTAL_BUFFER_SIZE 512
 
 #define PHY_INIT_TIMEOUT 100000
-#define GFAR_PHY_CHANGE_TIME 2
 
-#define DEVICE_NAME "%s: Gianfar Ethernet Controller Version 1.2, "
 #define DRV_NAME "gfar-enet"
-extern const char gfar_driver_name[];
 extern const char gfar_driver_version[];
 
 /* MAXIMUM NUMBER OF QUEUES SUPPORTED */
-- 
1.7.9.1
