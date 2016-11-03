From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 01/10] amd-xgbe: Fix formatting of PCS register
 dump
Date: Thu, 3 Nov 2016 13:17:38 -0500
Message-ID: <20161103181738.7383.30314.stgit@tlendack-t1.amdoffice.net>
References: <20161103181727.7383.34446.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0080.outbound.protection.outlook.com ([104.47.40.80]:31168
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1758233AbcKCSRp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 14:17:45 -0400
In-Reply-To: <20161103181727.7383.34446.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the length value used for the PCS register dump so that the full
value can be displayed.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
index 84c5d29..e9b01fc 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
@@ -1257,33 +1257,33 @@ static void xgbe_dump_phy_registers(struct xgbe_prv_data *pdata)
 
 	dev_dbg(dev, "\n************* PHY Reg dump **********************\n");
 
-	dev_dbg(dev, "PCS Control Reg (%#04x) = %#04x\n", MDIO_CTRL1,
+	dev_dbg(dev, "PCS Control Reg (%#06x) = %#06x\n", MDIO_CTRL1,
 		XMDIO_READ(pdata, MDIO_MMD_PCS, MDIO_CTRL1));
-	dev_dbg(dev, "PCS Status Reg (%#04x) = %#04x\n", MDIO_STAT1,
+	dev_dbg(dev, "PCS Status Reg (%#06x) = %#06x\n", MDIO_STAT1,
 		XMDIO_READ(pdata, MDIO_MMD_PCS, MDIO_STAT1));
-	dev_dbg(dev, "Phy Id (PHYS ID 1 %#04x)= %#04x\n", MDIO_DEVID1,
+	dev_dbg(dev, "Phy Id (PHYS ID 1 %#06x)= %#06x\n", MDIO_DEVID1,
 		XMDIO_READ(pdata, MDIO_MMD_PCS, MDIO_DEVID1));
-	dev_dbg(dev, "Phy Id (PHYS ID 2 %#04x)= %#04x\n", MDIO_DEVID2,
+	dev_dbg(dev, "Phy Id (PHYS ID 2 %#06x)= %#06x\n", MDIO_DEVID2,
 		XMDIO_READ(pdata, MDIO_MMD_PCS, MDIO_DEVID2));
-	dev_dbg(dev, "Devices in Package (%#04x)= %#04x\n", MDIO_DEVS1,
+	dev_dbg(dev, "Devices in Package (%#06x)= %#06x\n", MDIO_DEVS1,
 		XMDIO_READ(pdata, MDIO_MMD_PCS, MDIO_DEVS1));
-	dev_dbg(dev, "Devices in Package (%#04x)= %#04x\n", MDIO_DEVS2,
+	dev_dbg(dev, "Devices in Package (%#06x)= %#06x\n", MDIO_DEVS2,
 		XMDIO_READ(pdata, MDIO_MMD_PCS, MDIO_DEVS2));
 
-	dev_dbg(dev, "Auto-Neg Control Reg (%#04x) = %#04x\n", MDIO_CTRL1,
+	dev_dbg(dev, "Auto-Neg Control Reg (%#06x) = %#06x\n", MDIO_CTRL1,
 		XMDIO_READ(pdata, MDIO_MMD_AN, MDIO_CTRL1));
-	dev_dbg(dev, "Auto-Neg Status Reg (%#04x) = %#04x\n", MDIO_STAT1,
+	dev_dbg(dev, "Auto-Neg Status Reg (%#06x) = %#06x\n", MDIO_STAT1,
 		XMDIO_READ(pdata, MDIO_MMD_AN, MDIO_STAT1));
-	dev_dbg(dev, "Auto-Neg Ad Reg 1 (%#04x) = %#04x\n",
+	dev_dbg(dev, "Auto-Neg Ad Reg 1 (%#06x) = %#06x\n",
 		MDIO_AN_ADVERTISE,
 		XMDIO_READ(pdata, MDIO_MMD_AN, MDIO_AN_ADVERTISE));
-	dev_dbg(dev, "Auto-Neg Ad Reg 2 (%#04x) = %#04x\n",
+	dev_dbg(dev, "Auto-Neg Ad Reg 2 (%#06x) = %#06x\n",
 		MDIO_AN_ADVERTISE + 1,
 		XMDIO_READ(pdata, MDIO_MMD_AN, MDIO_AN_ADVERTISE + 1));
-	dev_dbg(dev, "Auto-Neg Ad Reg 3 (%#04x) = %#04x\n",
+	dev_dbg(dev, "Auto-Neg Ad Reg 3 (%#06x) = %#06x\n",
 		MDIO_AN_ADVERTISE + 2,
 		XMDIO_READ(pdata, MDIO_MMD_AN, MDIO_AN_ADVERTISE + 2));
-	dev_dbg(dev, "Auto-Neg Completion Reg (%#04x) = %#04x\n",
+	dev_dbg(dev, "Auto-Neg Completion Reg (%#06x) = %#06x\n",
 		MDIO_AN_COMP_STAT,
 		XMDIO_READ(pdata, MDIO_MMD_AN, MDIO_AN_COMP_STAT));
 
