From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 05/11] net: dsa: mv88e6xxx: Add comment about family a device belongs to
Date: Fri, 11 Nov 2016 03:53:37 +0100
Message-ID: <1478832823-31471-6-git-send-email-andrew@lunn.ch>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34654 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964823AbcKKCzw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 21:55:52 -0500
In-Reply-To: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Knowing the family of device belongs to helps with picking the ops
implementation which is appropriate to the device. So add a comment to
each structure of ops.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 65f34f1999e7..d4fc12d7021a 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3152,6 +3152,7 @@ static int mv88e6xxx_set_eeprom(struct dsa_switch *ds,
 }
 
 static const struct mv88e6xxx_ops mv88e6085_ops = {
+	/* MV88E6XXX_FAMILY_6097 */
 	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
@@ -3162,6 +3163,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6095_ops = {
+	/* MV88E6XXX_FAMILY_6095 */
 	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
@@ -3172,6 +3174,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6123_ops = {
+	/* MV88E6XXX_FAMILY_6165 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_read,
 	.phy_write = mv88e6xxx_write,
@@ -3182,6 +3185,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6131_ops = {
+	/* MV88E6XXX_FAMILY_6185 */
 	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
@@ -3192,6 +3196,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6161_ops = {
+	/* MV88E6XXX_FAMILY_6165 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_read,
 	.phy_write = mv88e6xxx_write,
@@ -3202,6 +3207,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6165_ops = {
+	/* MV88E6XXX_FAMILY_6165 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_read,
 	.phy_write = mv88e6xxx_write,
@@ -3212,6 +3218,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6171_ops = {
+	/* MV88E6XXX_FAMILY_6351 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3223,6 +3230,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6172_ops = {
+	/* MV88E6XXX_FAMILY_6352 */
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -3236,6 +3244,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6175_ops = {
+	/* MV88E6XXX_FAMILY_6351 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3247,6 +3256,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6176_ops = {
+	/* MV88E6XXX_FAMILY_6352 */
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -3260,6 +3270,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6185_ops = {
+	/* MV88E6XXX_FAMILY_6185 */
 	.set_switch_mac = mv88e6xxx_g1_set_switch_mac,
 	.phy_read = mv88e6xxx_phy_ppu_read,
 	.phy_write = mv88e6xxx_phy_ppu_write,
@@ -3270,6 +3281,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6240_ops = {
+	/* MV88E6XXX_FAMILY_6352 */
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -3283,6 +3295,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
+	/* MV88E6XXX_FAMILY_6320 */
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -3295,6 +3308,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
+	/* MV88E6XXX_FAMILY_6321 */
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -3307,6 +3321,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
+	/* MV88E6XXX_FAMILY_6351 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3318,6 +3333,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6351_ops = {
+	/* MV88E6XXX_FAMILY_6351 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3329,6 +3345,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
+	/* MV88E6XXX_FAMILY_6352 */
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -3342,6 +3359,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
+	/* MV88E6XXX_FAMILY_6390 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
@@ -3352,6 +3370,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
+	/* MV88E6XXX_FAMILY_6390 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
-- 
2.10.2
