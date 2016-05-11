From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH net-next] phy: micrel: Use MICREL_PHY_ID_MASK definition
Date: Wed, 11 May 2016 17:02:05 -0300
Message-ID: <1462996925-7153-1-git-send-email-festevam@gmail.com>
Cc: f.fainelli@gmail.com, andrew@lunn.ch, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@nxp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:32769 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932150AbcEKUCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 16:02:16 -0400
Received: by mail-yw0-f195.google.com with SMTP id y6so5323835ywe.0
        for <netdev@vger.kernel.org>; Wed, 11 May 2016 13:02:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@nxp.com>

Replace the hardcoded mask 0x00fffff0 with MICREL_PHY_ID_MASK for
better readability.

Suggested-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
---
 drivers/net/phy/micrel.c | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 4516c8a..5a8fefc 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -726,7 +726,7 @@ static int kszphy_probe(struct phy_device *phydev)
 static struct phy_driver ksphy_driver[] = {
 {
 	.phy_id		= PHY_ID_KS8737,
-	.phy_id_mask	= 0x00fffff0,
+	.phy_id_mask	= MICREL_PHY_ID_MASK,
 	.name		= "Micrel KS8737",
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
@@ -781,7 +781,7 @@ static struct phy_driver ksphy_driver[] = {
 	.resume		= genphy_resume,
 }, {
 	.phy_id		= PHY_ID_KSZ8041,
-	.phy_id_mask	= 0x00fffff0,
+	.phy_id_mask	= MICREL_PHY_ID_MASK,
 	.name		= "Micrel KSZ8041",
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
 				| SUPPORTED_Asym_Pause),
@@ -800,7 +800,7 @@ static struct phy_driver ksphy_driver[] = {
 	.resume		= genphy_resume,
 }, {
 	.phy_id		= PHY_ID_KSZ8041RNLI,
-	.phy_id_mask	= 0x00fffff0,
+	.phy_id_mask	= MICREL_PHY_ID_MASK,
 	.name		= "Micrel KSZ8041RNLI",
 	.features	= PHY_BASIC_FEATURES |
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
@@ -819,7 +819,7 @@ static struct phy_driver ksphy_driver[] = {
 	.resume		= genphy_resume,
 }, {
 	.phy_id		= PHY_ID_KSZ8051,
-	.phy_id_mask	= 0x00fffff0,
+	.phy_id_mask	= MICREL_PHY_ID_MASK,
 	.name		= "Micrel KSZ8051",
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
 				| SUPPORTED_Asym_Pause),
@@ -857,7 +857,7 @@ static struct phy_driver ksphy_driver[] = {
 }, {
 	.phy_id		= PHY_ID_KSZ8081,
 	.name		= "Micrel KSZ8081 or KSZ8091",
-	.phy_id_mask	= 0x00fffff0,
+	.phy_id_mask	= MICREL_PHY_ID_MASK,
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8081_type,
@@ -875,7 +875,7 @@ static struct phy_driver ksphy_driver[] = {
 }, {
 	.phy_id		= PHY_ID_KSZ8061,
 	.name		= "Micrel KSZ8061",
-	.phy_id_mask	= 0x00fffff0,
+	.phy_id_mask	= MICREL_PHY_ID_MASK,
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
@@ -909,7 +909,7 @@ static struct phy_driver ksphy_driver[] = {
 	.write_mmd_indirect = ksz9021_wr_mmd_phyreg,
 }, {
 	.phy_id		= PHY_ID_KSZ9031,
-	.phy_id_mask	= 0x00fffff0,
+	.phy_id_mask	= MICREL_PHY_ID_MASK,
 	.name		= "Micrel KSZ9031 Gigabit PHY",
 	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
@@ -926,7 +926,7 @@ static struct phy_driver ksphy_driver[] = {
 	.resume		= genphy_resume,
 }, {
 	.phy_id		= PHY_ID_KSZ8873MLL,
-	.phy_id_mask	= 0x00fffff0,
+	.phy_id_mask	= MICREL_PHY_ID_MASK,
 	.name		= "Micrel KSZ8873MLL Switch",
 	.features	= (SUPPORTED_Pause | SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG,
@@ -940,7 +940,7 @@ static struct phy_driver ksphy_driver[] = {
 	.resume		= genphy_resume,
 }, {
 	.phy_id		= PHY_ID_KSZ886X,
-	.phy_id_mask	= 0x00fffff0,
+	.phy_id_mask	= MICREL_PHY_ID_MASK,
 	.name		= "Micrel KSZ886X Switch",
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
@@ -962,17 +962,17 @@ MODULE_LICENSE("GPL");
 
 static struct mdio_device_id __maybe_unused micrel_tbl[] = {
 	{ PHY_ID_KSZ9021, 0x000ffffe },
-	{ PHY_ID_KSZ9031, 0x00fffff0 },
+	{ PHY_ID_KSZ9031, MICREL_PHY_ID_MASK },
 	{ PHY_ID_KSZ8001, 0x00ffffff },
-	{ PHY_ID_KS8737, 0x00fffff0 },
+	{ PHY_ID_KS8737, MICREL_PHY_ID_MASK },
 	{ PHY_ID_KSZ8021, 0x00ffffff },
 	{ PHY_ID_KSZ8031, 0x00ffffff },
-	{ PHY_ID_KSZ8041, 0x00fffff0 },
-	{ PHY_ID_KSZ8051, 0x00fffff0 },
-	{ PHY_ID_KSZ8061, 0x00fffff0 },
-	{ PHY_ID_KSZ8081, 0x00fffff0 },
-	{ PHY_ID_KSZ8873MLL, 0x00fffff0 },
-	{ PHY_ID_KSZ886X, 0x00fffff0 },
+	{ PHY_ID_KSZ8041, MICREL_PHY_ID_MASK },
+	{ PHY_ID_KSZ8051, MICREL_PHY_ID_MASK },
+	{ PHY_ID_KSZ8061, MICREL_PHY_ID_MASK },
+	{ PHY_ID_KSZ8081, MICREL_PHY_ID_MASK },
+	{ PHY_ID_KSZ8873MLL, MICREL_PHY_ID_MASK },
+	{ PHY_ID_KSZ886X, MICREL_PHY_ID_MASK },
 	{ }
 };
 
-- 
1.9.1
