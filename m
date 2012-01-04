From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 6/6] r6040: place comments before code
Date: Wed,  4 Jan 2012 19:59:38 +0100
Message-ID: <1325703578-17275-7-git-send-email-florian@openwrt.org>
References: <1325703578-17275-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:60764 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756777Ab2ADS7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 13:59:51 -0500
In-Reply-To: <1325703578-17275-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

checkpatch.pl complained about the line exceding 80 columns, and the
comment was actually on the same line as the code, fix that.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index b8dc727..87aa439 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -735,9 +735,10 @@ static void r6040_mac_address(struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	u16 *adrp;
 
-	/* MAC operation register */
-	iowrite16(MAC_RST, ioaddr + MCR1); /* Reset MAC */
-	iowrite16(MAC_SM_RST, ioaddr + MAC_SM); /* Reset internal state machine */
+	/* Reset MAC */
+	iowrite16(MAC_RST, ioaddr + MCR1);
+	/* Reset internal state machine */
+	iowrite16(MAC_SM_RST, ioaddr + MAC_SM);
 	iowrite16(0, ioaddr + MAC_SM);
 	mdelay(5);
 
-- 
1.7.5.4
