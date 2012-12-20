From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] bnx2x: use ARRAY_SIZE where possible
Date: Thu, 20 Dec 2012 14:11:24 -0500
Message-ID: <1356030701-16284-16-git-send-email-sasha.levin@oracle.com>
References: <1356030701-16284-1-git-send-email-sasha.levin@oracle.com>
Cc: Sasha Levin <sasha.levin@oracle.com>
To: Eilon Greenstein <eilong@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1356030701-16284-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 09096b4..cb41f54 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -3659,7 +3659,7 @@ static void bnx2x_warpcore_enable_AN_KR2(struct bnx2x_phy *phy,
 	bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
 				 MDIO_WC_REG_CL49_USERB0_CTRL, (3<<6));
 
-	for (i = 0; i < sizeof(reg_set)/sizeof(struct bnx2x_reg_set); i++)
+	for (i = 0; i < ARRAY_SIZE(reg_set); i++)
 		bnx2x_cl45_write(bp, phy, reg_set[i].devad, reg_set[i].reg,
 				 reg_set[i].val);
 
@@ -3713,7 +3713,7 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 	};
 	DP(NETIF_MSG_LINK, "Enable Auto Negotiation for KR\n");
 	/* Set to default registers that may be overriden by 10G force */
-	for (i = 0; i < sizeof(reg_set)/sizeof(struct bnx2x_reg_set); i++)
+	for (i = 0; i < ARRAY_SIZE(reg_set); i++)
 		bnx2x_cl45_write(bp, phy, reg_set[i].devad, reg_set[i].reg,
 				 reg_set[i].val);
 
@@ -3854,7 +3854,7 @@ static void bnx2x_warpcore_set_10G_KR(struct bnx2x_phy *phy,
 		{MDIO_PMA_DEVAD, MDIO_WC_REG_PMD_KR_CONTROL, 0x2}
 	};
 
-	for (i = 0; i < sizeof(reg_set)/sizeof(struct bnx2x_reg_set); i++)
+	for (i = 0; i < ARRAY_SIZE(reg_set); i++)
 		bnx2x_cl45_write(bp, phy, reg_set[i].devad, reg_set[i].reg,
 				 reg_set[i].val);
 
@@ -4242,7 +4242,7 @@ static void bnx2x_warpcore_clear_regs(struct bnx2x_phy *phy,
 	bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
 				 MDIO_WC_REG_RX66_CONTROL, (3<<13));
 
-	for (i = 0; i < sizeof(wc_regs)/sizeof(struct bnx2x_reg_set); i++)
+	for (i = 0; i < ARRAY_SIZE(wc_regs); i++)
 		bnx2x_cl45_write(bp, phy, wc_regs[i].devad, wc_regs[i].reg,
 				 wc_regs[i].val);
 
@@ -9520,7 +9520,7 @@ static void bnx2x_save_848xx_spirom_version(struct bnx2x_phy *phy,
 	} else {
 		/* For 32-bit registers in 848xx, access via MDIO2ARM i/f. */
 		/* (1) set reg 0xc200_0014(SPI_BRIDGE_CTRL_2) to 0x03000000 */
-		for (i = 0; i < sizeof(reg_set)/sizeof(struct bnx2x_reg_set);
+		for (i = 0; i < ARRAY_SIZE(reg_set);
 		      i++)
 			bnx2x_cl45_write(bp, phy, reg_set[i].devad,
 					 reg_set[i].reg, reg_set[i].val);
@@ -9592,7 +9592,7 @@ static void bnx2x_848xx_set_led(struct bnx2x *bp,
 			 MDIO_PMA_DEVAD,
 			 MDIO_PMA_REG_8481_LINK_SIGNAL, val);
 
-	for (i = 0; i < sizeof(reg_set)/sizeof(struct bnx2x_reg_set); i++)
+	for (i = 0; i < ARRAY_SIZE(reg_set); i++)
 		bnx2x_cl45_write(bp, phy, reg_set[i].devad, reg_set[i].reg,
 				 reg_set[i].val);
 
@@ -13395,7 +13395,7 @@ static void bnx2x_disable_kr2(struct link_params *params,
 	};
 	DP(NETIF_MSG_LINK, "Disabling 20G-KR2\n");
 
-	for (i = 0; i < sizeof(reg_set)/sizeof(struct bnx2x_reg_set); i++)
+	for (i = 0; i < ARRAY_SIZE(reg_set); i++)
 		bnx2x_cl45_write(bp, phy, reg_set[i].devad, reg_set[i].reg,
 				 reg_set[i].val);
 	vars->link_attr_sync &= ~LINK_ATTR_SYNC_KR2_ENABLE;
-- 
1.8.0
