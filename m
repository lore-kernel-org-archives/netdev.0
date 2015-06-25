From: <shh.xie@gmail.com>
Subject: [PATCH] net/phy: Add Vitesse 8641 phy ID
Date: Thu, 25 Jun 2015 13:34:27 +0800
Message-ID: <1435210467-27729-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0070.outbound.protection.outlook.com ([207.46.100.70]:52992
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750786AbbFYHL6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2015 03:11:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

Vitesse VSC8641 is compatible with Vitesse 82xx

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
 drivers/net/phy/vitesse.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 76cad71..17cad18 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -66,6 +66,7 @@
 #define PHY_ID_VSC8244			0x000fc6c0
 #define PHY_ID_VSC8514			0x00070670
 #define PHY_ID_VSC8574			0x000704a0
+#define PHY_ID_VSC8641			0x00070431
 #define PHY_ID_VSC8662			0x00070660
 #define PHY_ID_VSC8221			0x000fc550
 #define PHY_ID_VSC8211			0x000fc4b0
@@ -272,6 +273,18 @@ static struct phy_driver vsc82xx_driver[] = {
 	.config_intr    = &vsc82xx_config_intr,
 	.driver         = { .owner = THIS_MODULE,},
 }, {
+	.phy_id         = PHY_ID_VSC8641,
+	.name           = "Vitesse VSC8641",
+	.phy_id_mask    = 0x000ffff0,
+	.features       = PHY_GBIT_FEATURES,
+	.flags          = PHY_HAS_INTERRUPT,
+	.config_init    = &vsc824x_config_init,
+	.config_aneg    = &vsc82x4_config_aneg,
+	.read_status    = &genphy_read_status,
+	.ack_interrupt  = &vsc824x_ack_interrupt,
+	.config_intr    = &vsc82xx_config_intr,
+	.driver         = { .owner = THIS_MODULE,},
+}, {
 	.phy_id         = PHY_ID_VSC8662,
 	.name           = "Vitesse VSC8662",
 	.phy_id_mask    = 0x000ffff0,
@@ -318,6 +331,7 @@ static struct mdio_device_id __maybe_unused vitesse_tbl[] = {
 	{ PHY_ID_VSC8244, 0x000fffc0 },
 	{ PHY_ID_VSC8514, 0x000ffff0 },
 	{ PHY_ID_VSC8574, 0x000ffff0 },
+	{ PHY_ID_VSC8641, 0x000ffff0 },
 	{ PHY_ID_VSC8662, 0x000ffff0 },
 	{ PHY_ID_VSC8221, 0x000ffff0 },
 	{ PHY_ID_VSC8211, 0x000ffff0 },
-- 
1.8.4.1
