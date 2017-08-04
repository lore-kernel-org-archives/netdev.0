From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH] net: phy: marvell: logical vs bitwise OR typo
Date: Fri, 4 Aug 2017 11:17:21 +0300
Message-ID: <20170804081720.2g6yuthplhc4rv6b@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41951 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751303AbdHDIRt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 04:17:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was supposed to be a bitwise OR but there is a || vs | typo.

Fixes: 864dc729d528 ("net: phy: marvell: Refactor m88e1121 RGMII delay configuration")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 361fe9927ef2..15cbcdba618a 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -83,7 +83,7 @@
 #define MII_88E1121_PHY_MSCR_REG	21
 #define MII_88E1121_PHY_MSCR_RX_DELAY	BIT(5)
 #define MII_88E1121_PHY_MSCR_TX_DELAY	BIT(4)
-#define MII_88E1121_PHY_MSCR_DELAY_MASK	(~(BIT(5) || BIT(4)))
+#define MII_88E1121_PHY_MSCR_DELAY_MASK	(~(BIT(5) | BIT(4)))
 
 #define MII_88E1121_MISC_TEST				0x1a
 #define MII_88E1510_MISC_TEST_TEMP_THRESHOLD_MASK	0x1f00
