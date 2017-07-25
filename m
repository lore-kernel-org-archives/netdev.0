From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH RFC 04/13] net: phy: add 1000Base-X to phy settings table
Date: Tue, 25 Jul 2017 15:02:52 +0100
Message-ID: <E1da0QG-0007LL-Vj@rmk-PC.armlinux.org.uk>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:50862 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751810AbdGYOC4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 10:02:56 -0400
In-Reply-To: <20170725140138.GK31807@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the missing 1000Base-X entry to the phy settings table.  This was
not included because the original code could not cope with more than
32 bits of link mode mask.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phy-core.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/phy/phy-core.c b/drivers/net/phy/phy-core.c
index c07845e77004..21f75ae244b3 100644
--- a/drivers/net/phy/phy-core.c
+++ b/drivers/net/phy/phy-core.c
@@ -90,6 +90,11 @@ static const struct phy_setting settings[] = {
 	{
 		.speed = SPEED_1000,
 		.duplex = DUPLEX_FULL,
+		.bit = ETHTOOL_LINK_MODE_1000baseX_Full_BIT,
+	},
+	{
+		.speed = SPEED_1000,
+		.duplex = DUPLEX_FULL,
 		.bit = ETHTOOL_LINK_MODE_1000baseT_Full_BIT,
 	},
 	{
-- 
2.7.4
