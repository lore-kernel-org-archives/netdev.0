From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 3/6] net: phy: marvell: Checkpatch - assignments and comparisons
Date: Wed, 17 May 2017 03:26:01 +0200
Message-ID: <1494984364-19496-4-git-send-email-andrew@lunn.ch>
References: <1494984364-19496-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32803 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752629AbdEQB1y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 21:27:54 -0400
In-Reply-To: <1494984364-19496-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid multiple assignments
Comparisons should place the constant on the right side of the test

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index f52656ec618f..e9632f576a24 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -1101,7 +1101,7 @@ static int marvell_read_status_page(struct phy_device *phydev, int page)
 	if (err)
 		return err;
 
-	if (AUTONEG_ENABLE == phydev->autoneg) {
+	if (phydev->autoneg == AUTONEG_ENABLE) {
 		status = phy_read(phydev, MII_M1011_PHY_STATUS);
 		if (status < 0)
 			return status;
@@ -1126,7 +1126,8 @@ static int marvell_read_status_page(struct phy_device *phydev, int page)
 			phydev->duplex = DUPLEX_HALF;
 
 		status = status & MII_M1011_PHY_STATUS_SPD_MASK;
-		phydev->pause = phydev->asym_pause = 0;
+		phydev->pause = 0;
+		phydev->asym_pause = 0;
 
 		switch (status) {
 		case MII_M1011_PHY_STATUS_1000:
@@ -1185,7 +1186,8 @@ static int marvell_read_status_page(struct phy_device *phydev, int page)
 		else
 			phydev->speed = SPEED_10;
 
-		phydev->pause = phydev->asym_pause = 0;
+		phydev->pause = 0;
+		phydev->asym_pause = 0;
 		phydev->lp_advertising = 0;
 	}
 
-- 
2.11.0
