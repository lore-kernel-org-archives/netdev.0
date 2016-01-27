From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net 2/2] DT: phy.txt: Clarify expected compatible values
Date: Wed, 27 Jan 2016 01:11:39 +0100
Message-ID: <1453853499-11248-3-git-send-email-andrew@lunn.ch>
References: <1453853499-11248-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	aaro.koskinen@nokia.com, olof@lixom.net,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43335 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751803AbcA0ALt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2016 19:11:49 -0500
In-Reply-To: <1453853499-11248-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PHY devices may only list clause 22, 45, and their PHY identifier
values as compatible values. No other compatible strings are allowed.
Make this clear in the documentation, and remove examples where
make/model compatible strings are listed.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 Documentation/devicetree/bindings/net/brcm,bcmgenet.txt | 4 ++--
 Documentation/devicetree/bindings/net/mdio-mux-gpio.txt | 8 --------
 Documentation/devicetree/bindings/net/mdio-mux.txt      | 8 --------
 Documentation/devicetree/bindings/net/phy.txt           | 6 ++++--
 4 files changed, 6 insertions(+), 20 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/brcm,bcmgenet.txt b/Documentation/devicetree/bindings/net/brcm,bcmgenet.txt
index 451fef26b4df..10587bdadbbe 100644
--- a/Documentation/devicetree/bindings/net/brcm,bcmgenet.txt
+++ b/Documentation/devicetree/bindings/net/brcm,bcmgenet.txt
@@ -68,7 +68,7 @@ ethernet@f0b60000 {
 		phy1: ethernet-phy@1 {
 			max-speed = <1000>;
 			reg = <0x1>;
-			compatible = "brcm,28nm-gphy", "ethernet-phy-ieee802.3-c22";
+			compatible = "ethernet-phy-ieee802.3-c22";
 		};
 	};
 };
@@ -115,7 +115,7 @@ ethernet@f0ba0000 {
 		phy0: ethernet-phy@0 {
 			max-speed = <1000>;
 			reg = <0x0>;
-			compatible = "brcm,bcm53125", "ethernet-phy-ieee802.3-c22";
+			compatible = "ethernet-phy-ieee802.3-c22";
 		};
 	};
 };
diff --git a/Documentation/devicetree/bindings/net/mdio-mux-gpio.txt b/Documentation/devicetree/bindings/net/mdio-mux-gpio.txt
index 79384113c2b0..694987d3c17a 100644
--- a/Documentation/devicetree/bindings/net/mdio-mux-gpio.txt
+++ b/Documentation/devicetree/bindings/net/mdio-mux-gpio.txt
@@ -38,7 +38,6 @@ Example :
 
 			phy11: ethernet-phy@1 {
 				reg = <1>;
-				compatible = "marvell,88e1149r";
 				marvell,reg-init = <3 0x10 0 0x5777>,
 					<3 0x11 0 0x00aa>,
 					<3 0x12 0 0x4105>,
@@ -48,7 +47,6 @@ Example :
 			};
 			phy12: ethernet-phy@2 {
 				reg = <2>;
-				compatible = "marvell,88e1149r";
 				marvell,reg-init = <3 0x10 0 0x5777>,
 					<3 0x11 0 0x00aa>,
 					<3 0x12 0 0x4105>,
@@ -58,7 +56,6 @@ Example :
 			};
 			phy13: ethernet-phy@3 {
 				reg = <3>;
-				compatible = "marvell,88e1149r";
 				marvell,reg-init = <3 0x10 0 0x5777>,
 					<3 0x11 0 0x00aa>,
 					<3 0x12 0 0x4105>,
@@ -68,7 +65,6 @@ Example :
 			};
 			phy14: ethernet-phy@4 {
 				reg = <4>;
-				compatible = "marvell,88e1149r";
 				marvell,reg-init = <3 0x10 0 0x5777>,
 					<3 0x11 0 0x00aa>,
 					<3 0x12 0 0x4105>,
@@ -85,7 +81,6 @@ Example :
 
 			phy21: ethernet-phy@1 {
 				reg = <1>;
-				compatible = "marvell,88e1149r";
 				marvell,reg-init = <3 0x10 0 0x5777>,
 					<3 0x11 0 0x00aa>,
 					<3 0x12 0 0x4105>,
@@ -95,7 +90,6 @@ Example :
 			};
 			phy22: ethernet-phy@2 {
 				reg = <2>;
-				compatible = "marvell,88e1149r";
 				marvell,reg-init = <3 0x10 0 0x5777>,
 					<3 0x11 0 0x00aa>,
 					<3 0x12 0 0x4105>,
@@ -105,7 +99,6 @@ Example :
 			};
 			phy23: ethernet-phy@3 {
 				reg = <3>;
-				compatible = "marvell,88e1149r";
 				marvell,reg-init = <3 0x10 0 0x5777>,
 					<3 0x11 0 0x00aa>,
 					<3 0x12 0 0x4105>,
@@ -115,7 +108,6 @@ Example :
 			};
 			phy24: ethernet-phy@4 {
 				reg = <4>;
-				compatible = "marvell,88e1149r";
 				marvell,reg-init = <3 0x10 0 0x5777>,
 					<3 0x11 0 0x00aa>,
 					<3 0x12 0 0x4105>,
diff --git a/Documentation/devicetree/bindings/net/mdio-mux.txt b/Documentation/devicetree/bindings/net/mdio-mux.txt
index f65606f8d632..491f5bd55203 100644
--- a/Documentation/devicetree/bindings/net/mdio-mux.txt
+++ b/Documentation/devicetree/bindings/net/mdio-mux.txt
@@ -47,7 +47,6 @@ Example :
 
 			phy11: ethernet-phy@1 {
 				reg = <1>;
-				compatible = "marvell,88e1149r";
 				marvell,reg-init = <3 0x10 0 0x5777>,
 					<3 0x11 0 0x00aa>,
 					<3 0x12 0 0x4105>,
@@ -57,7 +56,6 @@ Example :
 			};
 			phy12: ethernet-phy@2 {
 				reg = <2>;
-				compatible = "marvell,88e1149r";
 				marvell,reg-init = <3 0x10 0 0x5777>,
 					<3 0x11 0 0x00aa>,
 					<3 0x12 0 0x4105>,
@@ -67,7 +65,6 @@ Example :
 			};
 			phy13: ethernet-phy@3 {
 				reg = <3>;
-				compatible = "marvell,88e1149r";
 				marvell,reg-init = <3 0x10 0 0x5777>,
 					<3 0x11 0 0x00aa>,
 					<3 0x12 0 0x4105>,
@@ -77,7 +74,6 @@ Example :
 			};
 			phy14: ethernet-phy@4 {
 				reg = <4>;
-				compatible = "marvell,88e1149r";
 				marvell,reg-init = <3 0x10 0 0x5777>,
 					<3 0x11 0 0x00aa>,
 					<3 0x12 0 0x4105>,
@@ -94,7 +90,6 @@ Example :
 
 			phy21: ethernet-phy@1 {
 				reg = <1>;
-				compatible = "marvell,88e1149r";
 				marvell,reg-init = <3 0x10 0 0x5777>,
 					<3 0x11 0 0x00aa>,
 					<3 0x12 0 0x4105>,
@@ -104,7 +99,6 @@ Example :
 			};
 			phy22: ethernet-phy@2 {
 				reg = <2>;
-				compatible = "marvell,88e1149r";
 				marvell,reg-init = <3 0x10 0 0x5777>,
 					<3 0x11 0 0x00aa>,
 					<3 0x12 0 0x4105>,
@@ -114,7 +108,6 @@ Example :
 			};
 			phy23: ethernet-phy@3 {
 				reg = <3>;
-				compatible = "marvell,88e1149r";
 				marvell,reg-init = <3 0x10 0 0x5777>,
 					<3 0x11 0 0x00aa>,
 					<3 0x12 0 0x4105>,
@@ -124,7 +117,6 @@ Example :
 			};
 			phy24: ethernet-phy@4 {
 				reg = <4>;
-				compatible = "marvell,88e1149r";
 				marvell,reg-init = <3 0x10 0 0x5777>,
 					<3 0x11 0 0x00aa>,
 					<3 0x12 0 0x4105>,
diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
index 525e1658f2da..bc1c3c8bf8fa 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -17,8 +17,7 @@ Optional Properties:
   "ethernet-phy-ieee802.3-c22" or "ethernet-phy-ieee802.3-c45" for
   PHYs that implement IEEE802.3 clause 22 or IEEE802.3 clause 45
   specifications. If neither of these are specified, the default is to
-  assume clause 22. The compatible list may also contain other
-  elements.
+  assume clause 22.
 
   If the phy's identifier is known then the list may contain an entry
   of the form: "ethernet-phy-idAAAA.BBBB" where
@@ -28,6 +27,9 @@ Optional Properties:
             4 hex digits. This is the chip vendor OUI bits 19:24,
             followed by 10 bits of a vendor specific ID.
 
+  The compatible list should not contain other values than those
+  listed here.
+
 - max-speed: Maximum PHY supported speed (10, 100, 1000...)
 
 - broken-turn-around: If set, indicates the PHY device does not correctly
-- 
2.7.0
