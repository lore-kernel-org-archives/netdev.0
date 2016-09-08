From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH net-next 1/1] net: phy: Fixed checkpatch errors for Microsemi PHYs.
Date: Thu, 8 Sep 2016 14:09:31 +0530
Message-ID: <1473323971-4041-1-git-send-email-Raju.Lakkaraju@microsemi.com>
References: <20160816194803.GA3751@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0071.outbound.protection.outlook.com ([104.47.38.71]:51155
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754213AbcIHIjp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 04:39:45 -0400
In-Reply-To: <20160816194803.GA3751@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

The existing VSC85xx PHY driver did not follow the coding style and caused "checkpatch" to complain. This commit fixes this.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 drivers/net/phy/Kconfig |   6 +-
 drivers/net/phy/mscc.c  | 178 ++++++++++++++++++++++++------------------------
 2 files changed, 92 insertions(+), 92 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 1c3e07c..87b566f 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -274,9 +274,9 @@ config MICROCHIP_PHY
 	  Supports the LAN88XX PHYs.
 
 config MICROSEMI_PHY
-    tristate "Microsemi PHYs"
-    ---help---
-      Currently supports the VSC8531 and VSC8541 PHYs
+	tristate "Microsemi PHYs"
+	---help---
+	  Currently supports the VSC8531 and VSC8541 PHYs
 
 config NATIONAL_PHY
 	tristate "National Semiconductor PHYs"
diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index ad33390..c09cc4a 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -13,135 +13,135 @@
 #include <linux/phy.h>
 
 enum rgmii_rx_clock_delay {
-       RGMII_RX_CLK_DELAY_0_2_NS = 0,
-       RGMII_RX_CLK_DELAY_0_8_NS = 1,
-       RGMII_RX_CLK_DELAY_1_1_NS = 2,
-       RGMII_RX_CLK_DELAY_1_7_NS = 3,
-       RGMII_RX_CLK_DELAY_2_0_NS = 4,
-       RGMII_RX_CLK_DELAY_2_3_NS = 5,
-       RGMII_RX_CLK_DELAY_2_6_NS = 6,
-       RGMII_RX_CLK_DELAY_3_4_NS = 7
+	RGMII_RX_CLK_DELAY_0_2_NS = 0,
+	RGMII_RX_CLK_DELAY_0_8_NS = 1,
+	RGMII_RX_CLK_DELAY_1_1_NS = 2,
+	RGMII_RX_CLK_DELAY_1_7_NS = 3,
+	RGMII_RX_CLK_DELAY_2_0_NS = 4,
+	RGMII_RX_CLK_DELAY_2_3_NS = 5,
+	RGMII_RX_CLK_DELAY_2_6_NS = 6,
+	RGMII_RX_CLK_DELAY_3_4_NS = 7
 };
 
-#define MII_VSC85XX_INT_MASK              25
-#define MII_VSC85XX_INT_MASK_MASK         0xa000
-#define MII_VSC85XX_INT_STATUS            26
+#define MII_VSC85XX_INT_MASK		  25
+#define MII_VSC85XX_INT_MASK_MASK	  0xa000
+#define MII_VSC85XX_INT_STATUS		  26
 
-#define MSCC_EXT_PAGE_ACCESS              31
-#define MSCC_PHY_PAGE_STANDARD            0x0000 /* Standard registers */
-#define MSCC_PHY_PAGE_EXTENDED_2          0x0002 /* Extended reg - page 2 */
+#define MSCC_EXT_PAGE_ACCESS		  31
+#define MSCC_PHY_PAGE_STANDARD		  0x0000 /* Standard registers */
+#define MSCC_PHY_PAGE_EXTENDED_2	  0x0002 /* Extended reg - page 2 */
 
 /* Extended Page 2 Registers */
-#define MSCC_PHY_RGMII_CNTL                       20
-#define RGMII_RX_CLK_DELAY_MASK                   0x0070
-#define RGMII_RX_CLK_DELAY_POS            4
+#define MSCC_PHY_RGMII_CNTL		  20
+#define RGMII_RX_CLK_DELAY_MASK		  0x0070
+#define RGMII_RX_CLK_DELAY_POS		  4
 
 /* Microsemi PHY ID's */
-#define PHY_ID_VSC8531                            0x00070570
-#define PHY_ID_VSC8541                            0x00070770
+#define PHY_ID_VSC8531			  0x00070570
+#define PHY_ID_VSC8541			  0x00070770
 
 static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 {
-       int rc;
+	int rc;
 
-       rc = phy_write(phydev, MSCC_EXT_PAGE_ACCESS, page);
-       return rc;
+	rc = phy_write(phydev, MSCC_EXT_PAGE_ACCESS, page);
+	return rc;
 }
 
 static int vsc85xx_default_config(struct phy_device *phydev)
 {
-       int rc;
-       u16 reg_val;
+	int rc;
+	u16 reg_val;
 
-       mutex_lock(&phydev->lock);
-       rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
-       if (rc != 0)
-               goto out_unlock;
+	mutex_lock(&phydev->lock);
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
+	if (rc != 0)
+		goto out_unlock;
 
-       reg_val = phy_read(phydev, MSCC_PHY_RGMII_CNTL);
-       reg_val &= ~(RGMII_RX_CLK_DELAY_MASK);
-       reg_val |= (RGMII_RX_CLK_DELAY_1_1_NS << RGMII_RX_CLK_DELAY_POS);
-       phy_write(phydev, MSCC_PHY_RGMII_CNTL, reg_val);
-       rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
+	reg_val = phy_read(phydev, MSCC_PHY_RGMII_CNTL);
+	reg_val &= ~(RGMII_RX_CLK_DELAY_MASK);
+	reg_val |= (RGMII_RX_CLK_DELAY_1_1_NS << RGMII_RX_CLK_DELAY_POS);
+	phy_write(phydev, MSCC_PHY_RGMII_CNTL, reg_val);
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
 
 out_unlock:
-       mutex_unlock(&phydev->lock);
+	mutex_unlock(&phydev->lock);
 
-       return rc;
+	return rc;
 }
 
 static int vsc85xx_config_init(struct phy_device *phydev)
 {
-       int rc;
+	int rc;
 
-       rc = vsc85xx_default_config(phydev);
-       if (rc)
-               return rc;
-       rc = genphy_config_init(phydev);
+	rc = vsc85xx_default_config(phydev);
+	if (rc)
+		return rc;
+	rc = genphy_config_init(phydev);
 
-       return rc;
+	return rc;
 }
 
 static int vsc85xx_ack_interrupt(struct phy_device *phydev)
 {
-       int rc = 0;
+	int rc = 0;
 
-       if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
-               rc = phy_read(phydev, MII_VSC85XX_INT_STATUS);
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		rc = phy_read(phydev, MII_VSC85XX_INT_STATUS);
 
-       return (rc < 0) ? rc : 0;
+	return (rc < 0) ? rc : 0;
 }
 
 static int vsc85xx_config_intr(struct phy_device *phydev)
 {
-       int rc;
-
-       if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
-               rc = phy_write(phydev, MII_VSC85XX_INT_MASK,
-                                  MII_VSC85XX_INT_MASK_MASK);
-       } else {
-               rc = phy_write(phydev, MII_VSC85XX_INT_MASK, 0);
-               if (rc < 0)
-                       return rc;
-               rc = phy_read(phydev, MII_VSC85XX_INT_STATUS);
-       }
-
-       return rc;
+	int rc;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
+		rc = phy_write(phydev, MII_VSC85XX_INT_MASK,
+			       MII_VSC85XX_INT_MASK_MASK);
+	} else {
+		rc = phy_write(phydev, MII_VSC85XX_INT_MASK, 0);
+		if (rc < 0)
+			return rc;
+		rc = phy_read(phydev, MII_VSC85XX_INT_STATUS);
+	}
+
+	return rc;
 }
 
 /* Microsemi VSC85xx PHYs */
 static struct phy_driver vsc85xx_driver[] = {
 {
-       .phy_id                 = PHY_ID_VSC8531,
-       .name                   = "Microsemi VSC8531",
-       .phy_id_mask    = 0xfffffff0,
-       .features               = PHY_GBIT_FEATURES,
-       .flags                  = PHY_HAS_INTERRUPT,
-       .soft_reset             = &genphy_soft_reset,
-       .config_init    = &vsc85xx_config_init,
-       .config_aneg    = &genphy_config_aneg,
-       .aneg_done              = &genphy_aneg_done,
-       .read_status    = &genphy_read_status,
-       .ack_interrupt  = &vsc85xx_ack_interrupt,
-       .config_intr    = &vsc85xx_config_intr,
-       .suspend                = &genphy_suspend,
-       .resume                 = &genphy_resume,
+	.phy_id		= PHY_ID_VSC8531,
+	.name		= "Microsemi VSC8531",
+	.phy_id_mask    = 0xfffffff0,
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.soft_reset	= &genphy_soft_reset,
+	.config_init    = &vsc85xx_config_init,
+	.config_aneg    = &genphy_config_aneg,
+	.aneg_done	= &genphy_aneg_done,
+	.read_status    = &genphy_read_status,
+	.ack_interrupt  = &vsc85xx_ack_interrupt,
+	.config_intr    = &vsc85xx_config_intr,
+	.suspend	= &genphy_suspend,
+	.resume		= &genphy_resume,
 },
 {
-       .phy_id                 = PHY_ID_VSC8541,
-       .name                   = "Microsemi VSC8541 SyncE",
-       .phy_id_mask    = 0xfffffff0,
-       .features               = PHY_GBIT_FEATURES,
-       .flags                  = PHY_HAS_INTERRUPT,
-       .soft_reset             = &genphy_soft_reset,
-       .config_init    = &vsc85xx_config_init,
-       .config_aneg    = &genphy_config_aneg,
-       .aneg_done              = &genphy_aneg_done,
-       .read_status    = &genphy_read_status,
-       .ack_interrupt  = &vsc85xx_ack_interrupt,
-       .config_intr    = &vsc85xx_config_intr,
-       .suspend                = &genphy_suspend,
-       .resume                 = &genphy_resume,
+	.phy_id		= PHY_ID_VSC8541,
+	.name		= "Microsemi VSC8541 SyncE",
+	.phy_id_mask    = 0xfffffff0,
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.soft_reset	= &genphy_soft_reset,
+	.config_init    = &vsc85xx_config_init,
+	.config_aneg    = &genphy_config_aneg,
+	.aneg_done	= &genphy_aneg_done,
+	.read_status    = &genphy_read_status,
+	.ack_interrupt  = &vsc85xx_ack_interrupt,
+	.config_intr    = &vsc85xx_config_intr,
+	.suspend	= &genphy_suspend,
+	.resume		= &genphy_resume,
 }
 
 };
@@ -149,9 +149,9 @@ static struct phy_driver vsc85xx_driver[] = {
 module_phy_driver(vsc85xx_driver);
 
 static struct mdio_device_id __maybe_unused vsc85xx_tbl[] = {
-       { PHY_ID_VSC8531, 0xfffffff0, },
-       { PHY_ID_VSC8541, 0xfffffff0, },
-       { }
+	{ PHY_ID_VSC8531, 0xfffffff0, },
+	{ PHY_ID_VSC8541, 0xfffffff0, },
+	{ }
 };
 
 MODULE_DEVICE_TABLE(mdio, vsc85xx_tbl);
-- 
2.7.4
