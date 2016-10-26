From: Fabio Estevam <fabio.estevam@nxp.com>
Subject: [PATCH net-next] net: phy: at803x: Add a definition for PHY ID mask
Date: Wed, 26 Oct 2016 14:03:54 -0200
Message-ID: <1477497834-9964-1-git-send-email-fabio.estevam@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0075.outbound.protection.outlook.com ([104.47.36.75]:21600
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933807AbcJZQhJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Oct 2016 12:37:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a definition for PHY ID mask for improving code readability.

Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
---
 drivers/net/phy/at803x.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index f279a89..dd47b69 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -58,6 +58,7 @@
 #define ATH8030_PHY_ID 0x004dd076
 #define ATH8031_PHY_ID 0x004dd074
 #define ATH8035_PHY_ID 0x004dd072
+#define AT803X_PHY_ID_MASK			0xffffffef
 
 MODULE_DESCRIPTION("Atheros 803x PHY driver");
 MODULE_AUTHOR("Matus Ujhelyi");
@@ -386,7 +387,7 @@ static struct phy_driver at803x_driver[] = {
 	/* ATHEROS 8035 */
 	.phy_id			= ATH8035_PHY_ID,
 	.name			= "Atheros 8035 ethernet",
-	.phy_id_mask		= 0xffffffef,
+	.phy_id_mask		= AT803X_PHY_ID_MASK,
 	.probe			= at803x_probe,
 	.config_init		= at803x_config_init,
 	.set_wol		= at803x_set_wol,
@@ -403,7 +404,7 @@ static struct phy_driver at803x_driver[] = {
 	/* ATHEROS 8030 */
 	.phy_id			= ATH8030_PHY_ID,
 	.name			= "Atheros 8030 ethernet",
-	.phy_id_mask		= 0xffffffef,
+	.phy_id_mask		= AT803X_PHY_ID_MASK,
 	.probe			= at803x_probe,
 	.config_init		= at803x_config_init,
 	.link_change_notify	= at803x_link_change_notify,
@@ -421,7 +422,7 @@ static struct phy_driver at803x_driver[] = {
 	/* ATHEROS 8031 */
 	.phy_id			= ATH8031_PHY_ID,
 	.name			= "Atheros 8031 ethernet",
-	.phy_id_mask		= 0xffffffef,
+	.phy_id_mask		= AT803X_PHY_ID_MASK,
 	.probe			= at803x_probe,
 	.config_init		= at803x_config_init,
 	.set_wol		= at803x_set_wol,
@@ -439,9 +440,9 @@ static struct phy_driver at803x_driver[] = {
 module_phy_driver(at803x_driver);
 
 static struct mdio_device_id __maybe_unused atheros_tbl[] = {
-	{ ATH8030_PHY_ID, 0xffffffef },
-	{ ATH8031_PHY_ID, 0xffffffef },
-	{ ATH8035_PHY_ID, 0xffffffef },
+	{ ATH8030_PHY_ID, AT803X_PHY_ID_MASK },
+	{ ATH8031_PHY_ID, AT803X_PHY_ID_MASK },
+	{ ATH8035_PHY_ID, AT803X_PHY_ID_MASK },
 	{ }
 };
 
-- 
2.7.4
