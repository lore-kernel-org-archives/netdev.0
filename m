From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/6] net: phy: marvell: Checkpatch - Missing or extra blank lines
Date: Wed, 17 May 2017 03:26:00 +0200
Message-ID: <1494984364-19496-3-git-send-email-andrew@lunn.ch>
References: <1494984364-19496-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32794 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751104AbdEQB05 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 21:26:57 -0400
In-Reply-To: <1494984364-19496-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the extra blank lines, add one in where recommended.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 2aacbf8e0eb3..f52656ec618f 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -420,7 +420,6 @@ static int marvell_of_reg_init(struct phy_device *phydev)
 		ret = phy_write(phydev, reg, val);
 		if (ret < 0)
 			goto err;
-
 	}
 err:
 	if (current_page != saved_page) {
@@ -449,7 +448,6 @@ static int m88e1121_config_aneg(struct phy_device *phydev)
 		return err;
 
 	if (phy_interface_is_rgmii(phydev)) {
-
 		mscr = phy_read(phydev, MII_88E1121_PHY_MSCR_REG) &
 			MII_88E1121_PHY_MSCR_DELAY_MASK;
 
@@ -703,7 +701,6 @@ static int m88e1111_config_init(struct phy_device *phydev)
 	int temp;
 
 	if (phy_interface_is_rgmii(phydev)) {
-
 		temp = phy_read(phydev, MII_M1111_PHY_EXT_CR);
 		if (temp < 0)
 			return temp;
@@ -968,6 +965,7 @@ static int m88e1145_config_init(struct phy_device *phydev)
 
 	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
 		int temp = phy_read(phydev, MII_M1145_PHY_EXT_CR);
+
 		if (temp < 0)
 			return temp;
 
@@ -1312,6 +1310,7 @@ static int marvell_resume(struct phy_device *phydev)
 static int marvell_aneg_done(struct phy_device *phydev)
 {
 	int retval = phy_read(phydev, MII_M1011_PHY_STATUS);
+
 	return (retval < 0) ? retval : (retval & MII_M1011_PHY_STATUS_RESOLVED);
 }
 
-- 
2.11.0
