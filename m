From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/6] net: phy: Marvell: checkpatch - Comments
Date: Wed, 17 May 2017 03:25:59 +0200
Message-ID: <1494984364-19496-2-git-send-email-andrew@lunn.ch>
References: <1494984364-19496-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32808 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751436AbdEQB20 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 21:28:26 -0400
In-Reply-To: <1494984364-19496-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use net style comment blocks, and wrap one block with long lines.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 272b051a0199..2aacbf8e0eb3 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -257,7 +257,8 @@ static int marvell_config_aneg(struct phy_device *phydev)
 
 	/* The Marvell PHY has an errata which requires
 	 * that certain registers get written in order
-	 * to restart autonegotiation */
+	 * to restart autonegotiation
+	 */
 	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
 
 	if (err < 0)
@@ -299,8 +300,7 @@ static int marvell_config_aneg(struct phy_device *phydev)
 	if (phydev->autoneg != AUTONEG_ENABLE) {
 		int bmcr;
 
-		/*
-		 * A write to speed/duplex bits (that is performed by
+		/* A write to speed/duplex bits (that is performed by
 		 * genphy_config_aneg() call above) must be followed by
 		 * a software reset. Otherwise, the write has no effect.
 		 */
@@ -359,8 +359,7 @@ static int m88e1111_config_aneg(struct phy_device *phydev)
 }
 
 #ifdef CONFIG_OF_MDIO
-/*
- * Set and/or override some configuration registers based on the
+/* Set and/or override some configuration registers based on the
  * marvell,reg-init property stored in the of_node for the phydev.
  *
  * marvell,reg-init = <reg-page reg mask value>,...;
@@ -1057,7 +1056,8 @@ static int marvell_update_link(struct phy_device *phydev, int fiber)
 	int status;
 
 	/* Use the generic register for copper link, or specific
-	 * register for fiber case */
+	 * register for fiber case
+	 */
 	if (fiber) {
 		status = phy_read(phydev, MII_M1011_PHY_STATUS);
 		if (status < 0)
@@ -1092,7 +1092,8 @@ static int marvell_read_status_page(struct phy_device *phydev, int page)
 	int fiber;
 
 	/* Detect and update the link, but return if there
-	 * was an error */
+	 * was an error
+	 */
 	if (page == MII_M1111_FIBER)
 		fiber = 1;
 	else
@@ -1217,12 +1218,13 @@ static int marvell_read_status(struct phy_device *phydev)
 		if (err < 0)
 			goto error;
 
-		/* If the fiber link is up, it is the selected and used link.
-		 * In this case, we need to stay in the fiber page.
-		 * Please to be careful about that, avoid to restore Copper page
-		 * in other functions which could break the behaviour
-		 * for some fiber phy like 88E1512.
-		 * */
+		/* If the fiber link is up, it is the selected and
+		 * used link. In this case, we need to stay in the
+		 * fiber page. Please to be careful about that, avoid
+		 * to restore Copper page in other functions which
+		 * could break the behaviour for some fiber phy like
+		 * 88E1512.
+		 */
 		if (phydev->link)
 			return 0;
 
-- 
2.11.0
