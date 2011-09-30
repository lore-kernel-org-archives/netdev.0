From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH next 4/7] sc92031: use standard #defines from mii.h.
Date: Fri, 30 Sep 2011 12:38:02 +0200
Message-ID: <20110930103802.GE26727@electric-eye.fr.zoreil.com>
References: <20110930103604.GA26727@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54239 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757857Ab1I3Kjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 06:39:35 -0400
Content-Disposition: inline
In-Reply-To: <20110930103604.GA26727@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/sc92031.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/realtek/sc92031.c b/drivers/net/ethernet/realtek/sc92031.c
index 128f8eb..a284d64 100644
--- a/drivers/net/ethernet/realtek/sc92031.c
+++ b/drivers/net/ethernet/realtek/sc92031.c
@@ -31,6 +31,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
+#include <linux/mii.h>
 #include <linux/crc32.h>
 
 #include <asm/irq.h>
@@ -116,16 +117,9 @@ enum  silan_registers {
    TestD8     = 0xD8,
 };
 
-#define MII_BMCR            0        // Basic mode control register
-#define MII_BMSR            1        // Basic mode status register
 #define MII_JAB             16
 #define MII_OutputStatus    24
 
-#define BMCR_FULLDPLX       0x0100    // Full duplex
-#define BMCR_ANRESTART      0x0200    // Auto negotiation restart
-#define BMCR_ANENABLE       0x1000    // Enable auto negotiation
-#define BMCR_SPEED100       0x2000    // Select 100Mbps
-#define BMSR_LSTATUS        0x0004    // Link status
 #define PHY_16_JAB_ENB      0x1000
 #define PHY_16_PORT_ENB     0x1
 
-- 
1.7.6.2
