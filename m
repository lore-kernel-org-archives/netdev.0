From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 6/6] net: phy: marvell: checkpatch - Fix remaining long lines
Date: Wed, 17 May 2017 03:26:04 +0200
Message-ID: <1494984364-19496-7-git-send-email-andrew@lunn.ch>
References: <1494984364-19496-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32819 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752521AbdEQB3r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 21:29:47 -0400
In-Reply-To: <1494984364-19496-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fold lines longer than 80 characters

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index d510eda92af5..88cd97b44ba6 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -217,9 +217,11 @@ static int marvell_config_intr(struct phy_device *phydev)
 	int err;
 
 	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
-		err = phy_write(phydev, MII_M1011_IMASK, MII_M1011_IMASK_INIT);
+		err = phy_write(phydev, MII_M1011_IMASK,
+				MII_M1011_IMASK_INIT);
 	else
-		err = phy_write(phydev, MII_M1011_IMASK, MII_M1011_IMASK_CLEAR);
+		err = phy_write(phydev, MII_M1011_IMASK,
+				MII_M1011_IMASK_CLEAR);
 
 	return err;
 }
@@ -1394,7 +1396,8 @@ static int m88e1121_did_interrupt(struct phy_device *phydev)
 	return 0;
 }
 
-static void m88e1318_get_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol)
+static void m88e1318_get_wol(struct phy_device *phydev,
+			     struct ethtool_wolinfo *wol)
 {
 	wol->supported = WAKE_MAGIC;
 	wol->wolopts = 0;
@@ -1410,7 +1413,8 @@ static void m88e1318_get_wol(struct phy_device *phydev, struct ethtool_wolinfo *
 		return;
 }
 
-static int m88e1318_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol)
+static int m88e1318_set_wol(struct phy_device *phydev,
+			    struct ethtool_wolinfo *wol)
 {
 	int err, oldpage, temp;
 
-- 
2.11.0
