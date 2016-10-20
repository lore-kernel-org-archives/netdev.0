From: <shh.xie@gmail.com>
Subject: [PATCH net-next] net: phy: aquantia: add PHY ID of AQR106 and AQR107
Date: Thu, 20 Oct 2016 16:30:31 +0800
Message-ID: <1476952231-39131-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, Shaohui Xie <Shaohui.Xie@nxp.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0055.outbound.protection.outlook.com ([104.47.38.55]:44672
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750810AbcJTLRF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 07:17:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@nxp.com>

The AQR106 and AQR107 can use the existing driver.

Signed-off-by: Shaohui Xie <Shaohui.Xie@nxp.com>
---
 drivers/net/phy/aquantia.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/drivers/net/phy/aquantia.c b/drivers/net/phy/aquantia.c
index 09b0b0a..e8ae50e 100644
--- a/drivers/net/phy/aquantia.c
+++ b/drivers/net/phy/aquantia.c
@@ -21,6 +21,8 @@
 #define PHY_ID_AQ1202	0x03a1b445
 #define PHY_ID_AQ2104	0x03a1b460
 #define PHY_ID_AQR105	0x03a1b4a2
+#define PHY_ID_AQR106	0x03a1b4d0
+#define PHY_ID_AQR107	0x03a1b4e0
 #define PHY_ID_AQR405	0x03a1b4b0
 
 #define PHY_AQUANTIA_FEATURES	(SUPPORTED_10000baseT_Full | \
@@ -154,6 +156,30 @@ static struct phy_driver aquantia_driver[] = {
 	.read_status	= aquantia_read_status,
 },
 {
+	.phy_id		= PHY_ID_AQR106,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Aquantia AQR106",
+	.features	= PHY_AQUANTIA_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.aneg_done	= aquantia_aneg_done,
+	.config_aneg    = aquantia_config_aneg,
+	.config_intr	= aquantia_config_intr,
+	.ack_interrupt	= aquantia_ack_interrupt,
+	.read_status	= aquantia_read_status,
+},
+{
+	.phy_id		= PHY_ID_AQR107,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Aquantia AQR107",
+	.features	= PHY_AQUANTIA_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.aneg_done	= aquantia_aneg_done,
+	.config_aneg    = aquantia_config_aneg,
+	.config_intr	= aquantia_config_intr,
+	.ack_interrupt	= aquantia_ack_interrupt,
+	.read_status	= aquantia_read_status,
+},
+{
 	.phy_id		= PHY_ID_AQR405,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Aquantia AQR405",
@@ -173,6 +199,8 @@ static struct mdio_device_id __maybe_unused aquantia_tbl[] = {
 	{ PHY_ID_AQ1202, 0xfffffff0 },
 	{ PHY_ID_AQ2104, 0xfffffff0 },
 	{ PHY_ID_AQR105, 0xfffffff0 },
+	{ PHY_ID_AQR106, 0xfffffff0 },
+	{ PHY_ID_AQR107, 0xfffffff0 },
 	{ PHY_ID_AQR405, 0xfffffff0 },
 	{ }
 };
-- 
2.1.0.27.g96db324
