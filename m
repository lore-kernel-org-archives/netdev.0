From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 3/9] net: phy: micrel: use BIT macro
Date: Tue, 11 Nov 2014 20:00:09 +0100
Message-ID: <1415732415-10363-4-git-send-email-johan@kernel.org>
References: <1415732415-10363-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415732415-10363-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use BIT macro for bitmask definitions.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/phy/micrel.c | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 62ca9613a514..d962a2866bba 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -30,30 +30,30 @@
 
 /* Operation Mode Strap Override */
 #define MII_KSZPHY_OMSO				0x16
-#define KSZPHY_OMSO_B_CAST_OFF			(1 << 9)
-#define KSZPHY_OMSO_RMII_OVERRIDE		(1 << 1)
-#define KSZPHY_OMSO_MII_OVERRIDE		(1 << 0)
+#define KSZPHY_OMSO_B_CAST_OFF			BIT(9)
+#define KSZPHY_OMSO_RMII_OVERRIDE		BIT(1)
+#define KSZPHY_OMSO_MII_OVERRIDE		BIT(0)
 
 /* general Interrupt control/status reg in vendor specific block. */
 #define MII_KSZPHY_INTCS			0x1B
-#define	KSZPHY_INTCS_JABBER			(1 << 15)
-#define	KSZPHY_INTCS_RECEIVE_ERR		(1 << 14)
-#define	KSZPHY_INTCS_PAGE_RECEIVE		(1 << 13)
-#define	KSZPHY_INTCS_PARELLEL			(1 << 12)
-#define	KSZPHY_INTCS_LINK_PARTNER_ACK		(1 << 11)
-#define	KSZPHY_INTCS_LINK_DOWN			(1 << 10)
-#define	KSZPHY_INTCS_REMOTE_FAULT		(1 << 9)
-#define	KSZPHY_INTCS_LINK_UP			(1 << 8)
+#define	KSZPHY_INTCS_JABBER			BIT(15)
+#define	KSZPHY_INTCS_RECEIVE_ERR		BIT(14)
+#define	KSZPHY_INTCS_PAGE_RECEIVE		BIT(13)
+#define	KSZPHY_INTCS_PARELLEL			BIT(12)
+#define	KSZPHY_INTCS_LINK_PARTNER_ACK		BIT(11)
+#define	KSZPHY_INTCS_LINK_DOWN			BIT(10)
+#define	KSZPHY_INTCS_REMOTE_FAULT		BIT(9)
+#define	KSZPHY_INTCS_LINK_UP			BIT(8)
 #define	KSZPHY_INTCS_ALL			(KSZPHY_INTCS_LINK_UP |\
 						KSZPHY_INTCS_LINK_DOWN)
 
 /* general PHY control reg in vendor specific block. */
 #define	MII_KSZPHY_CTRL			0x1F
 /* bitmap of PHY register to set interrupt mode */
-#define KSZPHY_CTRL_INT_ACTIVE_HIGH		(1 << 9)
-#define KSZ9021_CTRL_INT_ACTIVE_HIGH		(1 << 14)
-#define KS8737_CTRL_INT_ACTIVE_HIGH		(1 << 14)
-#define KSZ8051_RMII_50MHZ_CLK			(1 << 7)
+#define KSZPHY_CTRL_INT_ACTIVE_HIGH		BIT(9)
+#define KSZ9021_CTRL_INT_ACTIVE_HIGH		BIT(14)
+#define KS8737_CTRL_INT_ACTIVE_HIGH		BIT(14)
+#define KSZ8051_RMII_50MHZ_CLK			BIT(7)
 
 /* Write/read to/from extended registers */
 #define MII_KSZPHY_EXTREG                       0x0b
@@ -400,8 +400,8 @@ static int ksz9031_config_init(struct phy_device *phydev)
 }
 
 #define KSZ8873MLL_GLOBAL_CONTROL_4	0x06
-#define KSZ8873MLL_GLOBAL_CONTROL_4_DUPLEX	(1 << 6)
-#define KSZ8873MLL_GLOBAL_CONTROL_4_SPEED	(1 << 4)
+#define KSZ8873MLL_GLOBAL_CONTROL_4_DUPLEX	BIT(6)
+#define KSZ8873MLL_GLOBAL_CONTROL_4_SPEED	BIT(4)
 static int ksz8873mll_read_status(struct phy_device *phydev)
 {
 	int regval;
-- 
2.0.4
