From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/2] net: dsa: mv88e6xxx: 6351 family also has RGMII delays
Date: Thu, 10 Nov 2016 15:44:01 +0100
Message-ID: <1478789041-16264-3-git-send-email-andrew@lunn.ch>
References: <1478789041-16264-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34166 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933541AbcKJOoi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 09:44:38 -0500
In-Reply-To: <1478789041-16264-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent refactoring of setting the MAC configuration broke setting
of RGMII delays, via the phy-mode, on the 6351 family. Add the missing
ops to the structure.

Fixes: 7340e5ecdbb1 ("net: dsa: mv88e6xxx: setup port's MAC")
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index c8f824d4ff26..d6d9d66b81ce 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3196,6 +3196,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
 };
 
@@ -3217,6 +3218,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
 };
 
@@ -3281,6 +3283,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
 };
 
@@ -3290,6 +3293,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
 	.port_set_link = mv88e6xxx_port_set_link,
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6352_port_set_rgmii_delay,
 	.port_set_speed = mv88e6185_port_set_speed,
 };
 
-- 
2.10.2
