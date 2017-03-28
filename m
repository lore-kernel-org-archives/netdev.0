From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/4] net: dsa: mv88e6xxx: reorder 88E6341 definitions
Date: Tue, 28 Mar 2017 13:50:33 -0400
Message-ID: <20170328175035.13897-3-vivien.didelot@savoirfairelinux.com>
References: <20170328175035.13897-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170328175035.13897-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The related mv88e6xxx_ops structure was misplaced. Reorder it correctly
to fix this.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 62 ++++++++++++++++++++--------------------
 1 file changed, 31 insertions(+), 31 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index df6d8604caf1..3918790c4a75 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3378,6 +3378,37 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.reset = mv88e6352_g1_reset,
 };
 
+static const struct mv88e6xxx_ops mv88e6341_ops = {
+	/* MV88E6XXX_FAMILY_6341 */
+	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
+	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
+	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
+	.phy_read = mv88e6xxx_g2_smi_phy_read,
+	.phy_write = mv88e6xxx_g2_smi_phy_write,
+	.port_set_link = mv88e6xxx_port_set_link,
+	.port_set_duplex = mv88e6xxx_port_set_duplex,
+	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
+	.port_set_speed = mv88e6390_port_set_speed,
+	.port_tag_remap = mv88e6095_port_tag_remap,
+	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
+	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
+	.port_set_ether_type = mv88e6351_port_set_ether_type,
+	.port_jumbo_config = mv88e6165_port_jumbo_config,
+	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
+	.port_pause_config = mv88e6097_port_pause_config,
+	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
+	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
+	.stats_snapshot = mv88e6390_g1_stats_snapshot,
+	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
+	.stats_get_strings = mv88e6320_stats_get_strings,
+	.stats_get_stats = mv88e6390_stats_get_stats,
+	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
+	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
+	.watchdog_ops = &mv88e6390_watchdog_ops,
+	.mgmt_rsvd2cpu =  mv88e6390_g1_mgmt_rsvd2cpu,
+	.reset = mv88e6352_g1_reset,
+};
+
 static const struct mv88e6xxx_ops mv88e6350_ops = {
 	/* MV88E6XXX_FAMILY_6351 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
@@ -3467,37 +3498,6 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.reset = mv88e6352_g1_reset,
 };
 
-static const struct mv88e6xxx_ops mv88e6341_ops = {
-	/* MV88E6XXX_FAMILY_6341 */
-	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
-	.set_eeprom = mv88e6xxx_g2_set_eeprom8,
-	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
-	.phy_read = mv88e6xxx_g2_smi_phy_read,
-	.phy_write = mv88e6xxx_g2_smi_phy_write,
-	.port_set_link = mv88e6xxx_port_set_link,
-	.port_set_duplex = mv88e6xxx_port_set_duplex,
-	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
-	.port_set_speed = mv88e6390_port_set_speed,
-	.port_tag_remap = mv88e6095_port_tag_remap,
-	.port_set_frame_mode = mv88e6351_port_set_frame_mode,
-	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
-	.port_set_ether_type = mv88e6351_port_set_ether_type,
-	.port_jumbo_config = mv88e6165_port_jumbo_config,
-	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
-	.port_pause_config = mv88e6097_port_pause_config,
-	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
-	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
-	.stats_snapshot = mv88e6390_g1_stats_snapshot,
-	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
-	.stats_get_strings = mv88e6320_stats_get_strings,
-	.stats_get_stats = mv88e6390_stats_get_stats,
-	.g1_set_cpu_port = mv88e6390_g1_set_cpu_port,
-	.g1_set_egress_port = mv88e6390_g1_set_egress_port,
-	.watchdog_ops = &mv88e6390_watchdog_ops,
-	.mgmt_rsvd2cpu =  mv88e6390_g1_mgmt_rsvd2cpu,
-	.reset = mv88e6352_g1_reset,
-};
-
 static const struct mv88e6xxx_ops mv88e6390_ops = {
 	/* MV88E6XXX_FAMILY_6390 */
 	.get_eeprom = mv88e6xxx_g2_get_eeprom8,
-- 
2.12.1
