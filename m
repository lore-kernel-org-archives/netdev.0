From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 7/8] net: dsa: mv88e6xxx: explicit compatible devices
Date: Wed,  8 Jun 2016 20:44:55 -0400
Message-ID: <20160609004456.5441-8-vivien.didelot@savoirfairelinux.com>
References: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48668 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424825AbcFIAp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 20:45:26 -0400
In-Reply-To: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks to the new device probing, we can explicit the exact switch model
in the device tree.

Name the driver "mv88e6xxx" and list all its compatible supported chips.

In the meantime, rename the of_device_id table to avoid confusion with a
later introduce matching function.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 Documentation/devicetree/bindings/net/dsa/dsa.txt  |  6 ++--
 .../devicetree/bindings/net/dsa/marvell.txt        | 19 +++++++++++-
 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts          |  6 ++--
 drivers/net/dsa/mv88e6xxx.c                        | 34 ++++++++++++++++------
 4 files changed, 49 insertions(+), 16 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index 9bbbe7f..cbd88a3 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -80,7 +80,7 @@ linked into one DSA cluster.
 	#size-cells = <0>;
 
 	switch0: switch0@0 {
-		compatible = "marvell,mv88e6085";
+		compatible = "marvell,mv88e6352";
 		#address-cells = <1>;
 		#size-cells = <0>;
 		reg = <0>;
@@ -135,7 +135,7 @@ linked into one DSA cluster.
 	#size-cells = <0>;
 
 	switch1: switch1@0 {
-		compatible = "marvell,mv88e6085";
+		compatible = "marvell,mv88e6352";
 		#address-cells = <1>;
 		#size-cells = <0>;
 		reg = <0>;
@@ -206,7 +206,7 @@ linked into one DSA cluster.
 	#size-cells = <0>;
 
 	switch2: switch2@0 {
-		compatible = "marvell,mv88e6085";
+		compatible = "marvell,mv88e6352";
 		#address-cells = <1>;
 		#size-cells = <0>;
 		reg = <0>;
diff --git a/Documentation/devicetree/bindings/net/dsa/marvell.txt b/Documentation/devicetree/bindings/net/dsa/marvell.txt
index 7629189..1a3a03d 100644
--- a/Documentation/devicetree/bindings/net/dsa/marvell.txt
+++ b/Documentation/devicetree/bindings/net/dsa/marvell.txt
@@ -14,7 +14,24 @@ The properties described here are those specific to Marvell devices.
 Additional required and optional properties can be found in dsa.txt.
 
 Required properties:
-- compatible           : Should be one of "marvell,mv88e6085",
+- compatible           : Should be one of:
+                         * "marvell,mv88e6085",
+                         * "marvell,mv88e6095",
+                         * "marvell,mv88e6123",
+                         * "marvell,mv88e6131",
+                         * "marvell,mv88e6161",
+                         * "marvell,mv88e6165",
+                         * "marvell,mv88e6171",
+                         * "marvell,mv88e6172",
+                         * "marvell,mv88e6175",
+                         * "marvell,mv88e6176",
+                         * "marvell,mv88e6185",
+                         * "marvell,mv88e6240",
+                         * "marvell,mv88e6320",
+                         * "marvell,mv88e6321",
+                         * "marvell,mv88e6350",
+                         * "marvell,mv88e6351",
+                         * "marvell,mv88e6352",
 - reg                  : Address on the MII bus for the switch.
 
 Optional properties:
diff --git a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
index 5c1fcab..8c67181 100644
--- a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
+++ b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
@@ -87,7 +87,7 @@
 			#size-cells = <0>;
 
 			switch0: switch0@0 {
-				compatible = "marvell,mv88e6085";
+				compatible = "marvell,mv88e6352";
 				#address-cells = <1>;
 				#size-cells = <0>;
 				reg = <0>;
@@ -142,7 +142,7 @@
 			#size-cells = <0>;
 
 			switch1: switch1@0 {
-				compatible = "marvell,mv88e6085";
+				compatible = "marvell,mv88e6352";
 				#address-cells = <1>;
 				#size-cells = <0>;
 				reg = <0>;
@@ -213,7 +213,7 @@
 			reg = <4>;
 
 			switch2: switch2@0 {
-				compatible = "marvell,mv88e6085";
+				compatible = "marvell,mv88e6185";
 				#address-cells = <1>;
 				#size-cells = <0>;
 				reg = <0>;
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 28070e5..4f07110 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3723,6 +3723,29 @@ static void mv88e6xxx_unregister_switch(struct mv88e6xxx_priv_state *ps)
 	dsa_unregister_switch(ps->ds);
 }
 
+static const struct of_device_id mv88e6xxx_of_id_table[] = {
+	{ .compatible = "marvell,mv88e6085", .data = (void *)MV88E6085 },
+	{ .compatible = "marvell,mv88e6095", .data = (void *)MV88E6095 },
+	{ .compatible = "marvell,mv88e6123", .data = (void *)MV88E6123 },
+	{ .compatible = "marvell,mv88e6131", .data = (void *)MV88E6131 },
+	{ .compatible = "marvell,mv88e6161", .data = (void *)MV88E6161 },
+	{ .compatible = "marvell,mv88e6165", .data = (void *)MV88E6165 },
+	{ .compatible = "marvell,mv88e6171", .data = (void *)MV88E6171 },
+	{ .compatible = "marvell,mv88e6172", .data = (void *)MV88E6172 },
+	{ .compatible = "marvell,mv88e6175", .data = (void *)MV88E6175 },
+	{ .compatible = "marvell,mv88e6176", .data = (void *)MV88E6176 },
+	{ .compatible = "marvell,mv88e6185", .data = (void *)MV88E6185 },
+	{ .compatible = "marvell,mv88e6240", .data = (void *)MV88E6240 },
+	{ .compatible = "marvell,mv88e6320", .data = (void *)MV88E6320 },
+	{ .compatible = "marvell,mv88e6321", .data = (void *)MV88E6321 },
+	{ .compatible = "marvell,mv88e6350", .data = (void *)MV88E6350 },
+	{ .compatible = "marvell,mv88e6351", .data = (void *)MV88E6351 },
+	{ .compatible = "marvell,mv88e6352", .data = (void *)MV88E6352 },
+	{ /* sentinel */ },
+};
+
+MODULE_DEVICE_TABLE(of, mv88e6xxx_of_id_table);
+
 int mv88e6xxx_probe(struct mdio_device *mdiodev)
 {
 	struct device *dev = &mdiodev->dev;
@@ -3772,19 +3795,12 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 	mv88e6xxx_mdio_unregister(ps);
 }
 
-static const struct of_device_id mv88e6xxx_of_match[] = {
-	{ .compatible = "marvell,mv88e6085" },
-	{ /* sentinel */ },
-};
-
-MODULE_DEVICE_TABLE(of, mv88e6xxx_of_match);
-
 static struct mdio_driver mv88e6xxx_driver = {
 	.probe	= mv88e6xxx_probe,
 	.remove = mv88e6xxx_remove,
 	.mdiodrv.driver = {
-		.name = "mv88e6085",
-		.of_match_table = mv88e6xxx_of_match,
+		.name = "mv88e6xxx",
+		.of_match_table = mv88e6xxx_of_id_table,
 	},
 };
 
-- 
2.8.3
