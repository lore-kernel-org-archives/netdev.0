From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/6]: ixp4xx_eth: Remove references to BUS_ID_SIZE.
Date: Tue, 26 May 2009 21:39:51 -0700 (PDT)
Message-ID: <20090526.213951.206459353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kay.sievers@vrfy.org, greg@kroah.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48667
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752030AbZE0Ejw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 00:39:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use MII_BUS_ID_SIZE instead.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/arm/ixp4xx_eth.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index a740053..322c49b 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -1149,7 +1149,7 @@ static int __devinit eth_init_one(struct platform_device *pdev)
 	struct net_device *dev;
 	struct eth_plat_info *plat = pdev->dev.platform_data;
 	u32 regs_phys;
-	char phy_id[BUS_ID_SIZE];
+	char phy_id[MII_BUS_ID_SIZE + 3];
 	int err;
 
 	if (!(dev = alloc_etherdev(sizeof(struct port))))
@@ -1207,7 +1207,7 @@ static int __devinit eth_init_one(struct platform_device *pdev)
 	__raw_writel(DEFAULT_CORE_CNTRL, &port->regs->core_control);
 	udelay(50);
 
-	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, "0", plat->phy);
+	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, "0", plat->phy);
 	port->phydev = phy_connect(dev, phy_id, &ixp4xx_adjust_link, 0,
 				   PHY_INTERFACE_MODE_MII);
 	if ((err = IS_ERR(port->phydev)))
-- 
1.6.3

