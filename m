From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 1/4] net: phy: marvell: #defines for copper and fibre pages
Date: Thu, 25 May 2017 21:42:05 +0200
Message-ID: <1495741328-25001-2-git-send-email-andrew@lunn.ch>
References: <1495741328-25001-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44929 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936895AbdEYTnz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 15:43:55 -0400
In-Reply-To: <1495741328-25001-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace magic numbers for PHY pages with symbolic names.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 88cd97b44ba6..bb067026353a 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -650,7 +650,7 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 
 	mdelay(500);
 
-	err = marvell_set_page(phydev, 0);
+	err = marvell_set_page(phydev, MII_M1111_COPPER);
 	if (err < 0)
 		return err;
 
@@ -662,7 +662,7 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	err = marvell_set_page(phydev, 2);
+	err = marvell_set_page(phydev, MII_88E1121_PHY_MSCR_PAGE);
 	if (err < 0)
 		return err;
 	temp = phy_read(phydev, MII_M1116R_CONTROL_REG_MAC);
@@ -671,7 +671,7 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 	err = phy_write(phydev, MII_M1116R_CONTROL_REG_MAC, temp);
 	if (err < 0)
 		return err;
-	err = marvell_set_page(phydev, 0);
+	err = marvell_set_page(phydev, MII_M1111_COPPER);
 	if (err < 0)
 		return err;
 
@@ -892,7 +892,7 @@ static int m88e1510_config_init(struct phy_device *phydev)
 			return err;
 
 		/* Reset page selection */
-		err = marvell_set_page(phydev, 0);
+		err = marvell_set_page(phydev, MII_M1111_COPPER);
 		if (err < 0)
 			return err;
 	}
@@ -922,7 +922,7 @@ static int m88e1118_config_init(struct phy_device *phydev)
 	int err;
 
 	/* Change address */
-	err = marvell_set_page(phydev, 2);
+	err = marvell_set_page(phydev, MII_88E1121_PHY_MSCR_PAGE);
 	if (err < 0)
 		return err;
 
@@ -932,7 +932,7 @@ static int m88e1118_config_init(struct phy_device *phydev)
 		return err;
 
 	/* Change address */
-	err = marvell_set_page(phydev, 3);
+	err = marvell_set_page(phydev, MII_88E1318S_PHY_LED_PAGE);
 	if (err < 0)
 		return err;
 
@@ -949,7 +949,7 @@ static int m88e1118_config_init(struct phy_device *phydev)
 		return err;
 
 	/* Reset address */
-	err = marvell_set_page(phydev, 0);
+	err = marvell_set_page(phydev, MII_M1111_COPPER);
 	if (err < 0)
 		return err;
 
@@ -961,7 +961,7 @@ static int m88e1149_config_init(struct phy_device *phydev)
 	int err;
 
 	/* Change address */
-	err = marvell_set_page(phydev, 2);
+	err = marvell_set_page(phydev, MII_88E1121_PHY_MSCR_PAGE);
 	if (err < 0)
 		return err;
 
@@ -975,7 +975,7 @@ static int m88e1149_config_init(struct phy_device *phydev)
 		return err;
 
 	/* Reset address */
-	err = marvell_set_page(phydev, 0);
+	err = marvell_set_page(phydev, MII_M1111_COPPER);
 	if (err < 0)
 		return err;
 
@@ -1409,7 +1409,7 @@ static void m88e1318_get_wol(struct phy_device *phydev,
 	    MII_88E1318S_PHY_WOL_CTRL_MAGIC_PACKET_MATCH_ENABLE)
 		wol->wolopts |= WAKE_MAGIC;
 
-	if (marvell_set_page(phydev, 0x00) < 0)
+	if (marvell_set_page(phydev, MII_M1111_COPPER) < 0)
 		return;
 }
 
@@ -1422,7 +1422,7 @@ static int m88e1318_set_wol(struct phy_device *phydev,
 
 	if (wol->wolopts & WAKE_MAGIC) {
 		/* Explicitly switch to page 0x00, just to be sure */
-		err = marvell_set_page(phydev, 0x00);
+		err = marvell_set_page(phydev, MII_M1111_COPPER);
 		if (err < 0)
 			return err;
 
-- 
2.11.0
