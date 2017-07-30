From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/7] net: phy: marvell: tabification
Date: Sun, 30 Jul 2017 22:41:44 +0200
Message-ID: <1501447310-24101-2-git-send-email-andrew@lunn.ch>
References: <1501447310-24101-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45254 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754442AbdG3UmS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Jul 2017 16:42:18 -0400
In-Reply-To: <1501447310-24101-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert spaces to tabs where appropriate, and fix up some otherwise
odd indentation.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 5d314f143aea..6a5256ceb11e 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -108,24 +108,24 @@
 #define MII_88E1318S_PHY_MSCR1_PAD_ODD	BIT(6)
 
 /* Copper Specific Interrupt Enable Register */
-#define MII_88E1318S_PHY_CSIER                              0x12
+#define MII_88E1318S_PHY_CSIER				0x12
 /* WOL Event Interrupt Enable */
-#define MII_88E1318S_PHY_CSIER_WOL_EIE                      BIT(7)
+#define MII_88E1318S_PHY_CSIER_WOL_EIE			BIT(7)
 
 /* LED Timer Control Register */
-#define MII_88E1318S_PHY_LED_TCR                            0x12
-#define MII_88E1318S_PHY_LED_TCR_FORCE_INT                  BIT(15)
-#define MII_88E1318S_PHY_LED_TCR_INTn_ENABLE                BIT(7)
-#define MII_88E1318S_PHY_LED_TCR_INT_ACTIVE_LOW             BIT(11)
+#define MII_88E1318S_PHY_LED_TCR			0x12
+#define MII_88E1318S_PHY_LED_TCR_FORCE_INT		BIT(15)
+#define MII_88E1318S_PHY_LED_TCR_INTn_ENABLE		BIT(7)
+#define MII_88E1318S_PHY_LED_TCR_INT_ACTIVE_LOW		BIT(11)
 
 /* Magic Packet MAC address registers */
-#define MII_88E1318S_PHY_MAGIC_PACKET_WORD2                 0x17
-#define MII_88E1318S_PHY_MAGIC_PACKET_WORD1                 0x18
-#define MII_88E1318S_PHY_MAGIC_PACKET_WORD0                 0x19
+#define MII_88E1318S_PHY_MAGIC_PACKET_WORD2		0x17
+#define MII_88E1318S_PHY_MAGIC_PACKET_WORD1		0x18
+#define MII_88E1318S_PHY_MAGIC_PACKET_WORD0		0x19
 
-#define MII_88E1318S_PHY_WOL_CTRL                           0x10
-#define MII_88E1318S_PHY_WOL_CTRL_CLEAR_WOL_STATUS          BIT(12)
-#define MII_88E1318S_PHY_WOL_CTRL_MAGIC_PACKET_MATCH_ENABLE BIT(14)
+#define MII_88E1318S_PHY_WOL_CTRL				0x10
+#define MII_88E1318S_PHY_WOL_CTRL_CLEAR_WOL_STATUS		BIT(12)
+#define MII_88E1318S_PHY_WOL_CTRL_MAGIC_PACKET_MATCH_ENABLE	BIT(14)
 
 #define MII_88E1121_PHY_LED_CTRL	16
 #define MII_88E1121_PHY_LED_DEF		0x0030
@@ -152,7 +152,7 @@
 #define LPA_FIBER_1000HALF	0x40
 #define LPA_FIBER_1000FULL	0x20
 
-#define LPA_PAUSE_FIBER	0x180
+#define LPA_PAUSE_FIBER		0x180
 #define LPA_PAUSE_ASYM_FIBER	0x100
 
 #define ADVERTISE_FIBER_1000HALF	0x40
@@ -596,7 +596,7 @@ static int marvell_config_aneg_fiber(struct phy_device *phydev)
 
 	if (changed == 0) {
 		/* Advertisement hasn't changed, but maybe aneg was never on to
-		 * begin with?  Or maybe phy was isolated?
+		 * begin with?	Or maybe phy was isolated?
 		 */
 		int ctl = phy_read(phydev, MII_BMCR);
 
@@ -1515,7 +1515,7 @@ static void marvell_get_strings(struct phy_device *phydev, u8 *data)
 }
 
 #ifndef UINT64_MAX
-#define UINT64_MAX              (u64)(~((u64)0))
+#define UINT64_MAX		(u64)(~((u64)0))
 #endif
 static u64 marvell_get_stat(struct phy_device *phydev, int i)
 {
-- 
2.13.2
