From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 05/11] net: dsa: mv88e6xxx: Add comment about family a device belongs to
Date: Mon, 21 Nov 2016 23:26:59 +0100
Message-ID: <1479767225-13789-6-git-send-email-andrew@lunn.ch>
References: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47706 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753260AbcKUW1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 17:27:24 -0500
In-Reply-To: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Knowing the family of device belongs to helps with picking the ops
implementation which is appropriate to the device. So add a comment to
each structure of ops.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 6e72877f125a..2ed7fc996176 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3146,6 +3146,7 @@ static int mv88e6xxx_set_eeprom(struct dsa_switch *ds,
 }
 
 static const struct mv88e6xxx_ops mv88e6085_ops = {
+	/* MV88E6XXX_FAMILY_6097 */
 	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
@@ -3156,6 +3157,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
+	/* MV88E6XXX_FAMILY_6095 */
 	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
@@ -3166,6 +3168,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
+	/* MV88E6XXX_FAMILY_6165 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_read,
 	.phy_write = mv88e6xxx_write,
@@ -3176,6 +3179,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
+	/* MV88E6XXX_FAMILY_6185 */
 	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
@@ -3186,6 +3190,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
+	/* MV88E6XXX_FAMILY_6165 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_read,
 	.phy_write = mv88e6xxx_write,
@@ -3196,6 +3201,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
+	/* MV88E6XXX_FAMILY_6165 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_read,
 	.phy_write = mv88e6xxx_write,
@@ -3206,6 +3212,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
+	/* MV88E6XXX_FAMILY_6351 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3217,6 +3224,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
+	/* MV88E6XXX_FAMILY_6352 */
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -3230,6 +3238,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
+	/* MV88E6XXX_FAMILY_6351 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3241,6 +3250,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
+	/* MV88E6XXX_FAMILY_6352 */
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -3254,6 +3264,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
+	/* MV88E6XXX_FAMILY_6185 */
 	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
@@ -3264,6 +3275,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6190_ops = {
+	/* MV88E6XXX_FAMILY_6390 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3274,6 +3286,7 @@ static const struct mv88e6xxx_ops mv88e6190_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6190x_ops = {
+	/* MV88E6XXX_FAMILY_6390 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3284,6 +3297,7 @@ static const struct mv88e6xxx_ops mv88e6190x_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6191_ops = {
+	/* MV88E6XXX_FAMILY_6390 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3294,6 +3308,7 @@ static const struct mv88e6xxx_ops mv88e6191_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
+	/* MV88E6XXX_FAMILY_6352 */
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -3307,6 +3322,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
+	/* MV88E6XXX_FAMILY_6390 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3317,6 +3333,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
+	/* MV88E6XXX_FAMILY_6320 */
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -3329,6 +3346,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
+	/* MV88E6XXX_FAMILY_6321 */
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -3341,6 +3359,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
+	/* MV88E6XXX_FAMILY_6351 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3352,6 +3371,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
+	/* MV88E6XXX_FAMILY_6351 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3363,6 +3383,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
+	/* MV88E6XXX_FAMILY_6352 */
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -3376,6 +3397,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
+	/* MV88E6XXX_FAMILY_6390 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3386,6 +3408,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
+	/* MV88E6XXX_FAMILY_6390 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3396,6 +3419,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6391_ops = {
+	/* MV88E6XXX_FAMILY_6390 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
-- 
2.10.2
