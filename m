From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] Doc: DT: bindings: net: dsa: marvell.txt: Tabification
Date: Wed, 25 Jan 2017 02:44:48 +0100
Message-ID: <1485308688-23670-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44688 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750966AbdAYBpH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 20:45:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace spaces with tabs. Fix indentation to be multiples of tabs, not
a mixture or tabs and spaces.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 .../devicetree/bindings/net/dsa/marvell.txt        | 112 ++++++++++-----------
 1 file changed, 56 insertions(+), 56 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/marvell.txt b/Documentation/devicetree/bindings/net/dsa/marvell.txt
index 64dbdd825981..7ef9dbb08957 100644
--- a/Documentation/devicetree/bindings/net/dsa/marvell.txt
+++ b/Documentation/devicetree/bindings/net/dsa/marvell.txt
@@ -14,9 +14,9 @@ The properties described here are those specific to Marvell devices.
 Additional required and optional properties can be found in dsa.txt.
 
 Required properties:
-- compatible	       : Should be one of "marvell,mv88e6085" or
-			 "marvell,mv88e6190"
-- reg                  : Address on the MII bus for the switch.
+- compatible		: Should be one of "marvell,mv88e6085" or
+			  "marvell,mv88e6190"
+- reg			: Address on the MII bus for the switch.
 
 Optional properties:
 
@@ -28,65 +28,65 @@ Optional properties:
 #interrupt-cells = <2>	: Controller uses two cells, number and flag
 - mdio			: Container of PHY and devices on the switches MDIO
 			  bus.
-- mdio?			: Container of PHYs and devices on the external MDIO
+- mdio?		: Container of PHYs and devices on the external MDIO
 			  bus. The node must contains a compatible string of
 			  "marvell,mv88e6xxx-mdio-external"
 
 Example:
 
-       mdio {
-               #address-cells = <1>;
-               #size-cells = <0>;
-               interrupt-parent = <&gpio0>;
-               interrupts = <27 IRQ_TYPE_LEVEL_LOW>;
-               interrupt-controller;
-               #interrupt-cells = <2>;
+	mdio {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		interrupt-parent = <&gpio0>;
+		interrupts = <27 IRQ_TYPE_LEVEL_LOW>;
+		interrupt-controller;
+		#interrupt-cells = <2>;
 
-               switch0: switch@0 {
-                       compatible = "marvell,mv88e6085";
-                       reg = <0>;
-		       reset-gpios = <&gpio5 1 GPIO_ACTIVE_LOW>;
-               };
-               mdio {
-                       #address-cells = <1>;
-                       #size-cells = <0>;
-                       switch1phy0: switch1phy0@0 {
-                               reg = <0>;
-                               interrupt-parent = <&switch0>;
-                               interrupts = <0 IRQ_TYPE_LEVEL_HIGH>;
-                       };
-               };
-       };
+		switch0: switch@0 {
+			compatible = "marvell,mv88e6085";
+			reg = <0>;
+			reset-gpios = <&gpio5 1 GPIO_ACTIVE_LOW>;
+		};
+		mdio {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			switch1phy0: switch1phy0@0 {
+				reg = <0>;
+				interrupt-parent = <&switch0>;
+				interrupts = <0 IRQ_TYPE_LEVEL_HIGH>;
+			};
+		};
+	};
 
-       mdio {
-               #address-cells = <1>;
-               #size-cells = <0>;
-               interrupt-parent = <&gpio0>;
-               interrupts = <27 IRQ_TYPE_LEVEL_LOW>;
-               interrupt-controller;
-               #interrupt-cells = <2>;
+	mdio {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		interrupt-parent = <&gpio0>;
+		interrupts = <27 IRQ_TYPE_LEVEL_LOW>;
+		interrupt-controller;
+		#interrupt-cells = <2>;
 
-               switch0: switch@0 {
-                       compatible = "marvell,mv88e6390";
-                       reg = <0>;
-		       reset-gpios = <&gpio5 1 GPIO_ACTIVE_LOW>;
-               };
-               mdio {
-                       #address-cells = <1>;
-                       #size-cells = <0>;
-                       switch1phy0: switch1phy0@0 {
-                               reg = <0>;
-                               interrupt-parent = <&switch0>;
-                               interrupts = <0 IRQ_TYPE_LEVEL_HIGH>;
-                       };
-               };
+		switch0: switch@0 {
+			compatible = "marvell,mv88e6390";
+			reg = <0>;
+			reset-gpios = <&gpio5 1 GPIO_ACTIVE_LOW>;
+		};
+		mdio {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			switch1phy0: switch1phy0@0 {
+				reg = <0>;
+				interrupt-parent = <&switch0>;
+				interrupts = <0 IRQ_TYPE_LEVEL_HIGH>;
+			};
+		};
 
-               mdio1 {
-                       compatible = "marvell,mv88e6xxx-mdio-external";
-                       #address-cells = <1>;
-                       #size-cells = <0>;
-                       switch1phy9: switch1phy0@9 {
-                               reg = <9>;
-                       };
-               };
-       };
+		mdio1 {
+			compatible = "marvell,mv88e6xxx-mdio-external";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			switch1phy9: switch1phy0@9 {
+				reg = <9>;
+			};
+		};
+	};
-- 
2.11.0
