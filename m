From: Shruti Kanetkar <Shruti@Freescale.com>
Subject: [PATCH] net/fsl: Add format length modifier to avoid negative values
Date: Tue, 29 Jul 2014 14:53:03 -0500
Message-ID: <1406663583-8824-1-git-send-email-Shruti@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Shruti Kanetkar <Shruti@Freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dns-bn1lp0143.outbound.protection.outlook.com ([207.46.163.143]:11842
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751234AbaG2TxJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 15:53:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Shruti Kanetkar <Shruti@Freescale.com>
---
 drivers/net/ethernet/freescale/xgmac_mdio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
index 8173407..6e7db66 100644
--- a/drivers/net/ethernet/freescale/xgmac_mdio.c
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -163,7 +163,7 @@ static int xgmac_mdio_read(struct mii_bus *bus, int phy_id, int regnum)
 	/* Return all Fs if nothing was there */
 	if (in_be32(&regs->mdio_stat) & MDIO_STAT_RD_ER) {
 		dev_err(&bus->dev,
-			"Error while reading PHY%d reg at %d.%d\n",
+			"Error while reading PHY%d reg at %d.%hhu\n",
 			phy_id, dev_addr, regnum);
 		return 0xffff;
 	}
-- 
1.8.3.1
