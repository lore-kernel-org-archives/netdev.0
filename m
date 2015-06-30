From: Simon Guinot <simon.guinot@sequanux.org>
Subject: [PATCH v3 2/3] ARM: mvebu: update Ethernet compatible string for Armada XP
Date: Tue, 30 Jun 2015 16:05:48 +0200
Message-ID: <1435673149-12599-3-git-send-email-simon.guinot@sequanux.org>
References: <1435673149-12599-1-git-send-email-simon.guinot@sequanux.org>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Vincent Donnefort <vdonnefort@gmail.com>,
	<stable@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1435673149-12599-1-git-send-email-simon.guinot@sequanux.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch updates the Ethernet DT nodes for Armada XP SoCs with the
compatible string "marvell,armada-xp-neta".

Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
Fixes: 77916519cba3 ("arm: mvebu: Armada XP MV78230 has only three Ethernet interfaces")
Cc: <stable@vger.kernel.org> # v3.8+
Acked-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 arch/arm/boot/dts/armada-370-xp.dtsi     |  2 --
 arch/arm/boot/dts/armada-370.dtsi        |  8 ++++++++
 arch/arm/boot/dts/armada-xp-mv78260.dtsi |  2 +-
 arch/arm/boot/dts/armada-xp-mv78460.dtsi |  2 +-
 arch/arm/boot/dts/armada-xp.dtsi         | 10 +++++++++-
 5 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/arch/arm/boot/dts/armada-370-xp.dtsi b/arch/arm/boot/dts/armada-370-xp.dtsi
index ec96f0b36346..06a2f2ae9d1e 100644
--- a/arch/arm/boot/dts/armada-370-xp.dtsi
+++ b/arch/arm/boot/dts/armada-370-xp.dtsi
@@ -270,7 +270,6 @@
 			};
 
 			eth0: ethernet@70000 {
-				compatible = "marvell,armada-370-neta";
 				reg = <0x70000 0x4000>;
 				interrupts = <8>;
 				clocks = <&gateclk 4>;
@@ -286,7 +285,6 @@
 			};
 
 			eth1: ethernet@74000 {
-				compatible = "marvell,armada-370-neta";
 				reg = <0x74000 0x4000>;
 				interrupts = <10>;
 				clocks = <&gateclk 3>;
diff --git a/arch/arm/boot/dts/armada-370.dtsi b/arch/arm/boot/dts/armada-370.dtsi
index 00b50db57c9c..ca4257b2f77d 100644
--- a/arch/arm/boot/dts/armada-370.dtsi
+++ b/arch/arm/boot/dts/armada-370.dtsi
@@ -307,6 +307,14 @@
 					dmacap,memset;
 				};
 			};
+
+			ethernet@70000 {
+				compatible = "marvell,armada-370-neta";
+			};
+
+			ethernet@74000 {
+				compatible = "marvell,armada-370-neta";
+			};
 		};
 	};
 };
diff --git a/arch/arm/boot/dts/armada-xp-mv78260.dtsi b/arch/arm/boot/dts/armada-xp-mv78260.dtsi
index 8479fdc9e9c2..c5fdc99f0dbe 100644
--- a/arch/arm/boot/dts/armada-xp-mv78260.dtsi
+++ b/arch/arm/boot/dts/armada-xp-mv78260.dtsi
@@ -318,7 +318,7 @@
 			};
 
 			eth3: ethernet@34000 {
-				compatible = "marvell,armada-370-neta";
+				compatible = "marvell,armada-xp-neta";
 				reg = <0x34000 0x4000>;
 				interrupts = <14>;
 				clocks = <&gateclk 1>;
diff --git a/arch/arm/boot/dts/armada-xp-mv78460.dtsi b/arch/arm/boot/dts/armada-xp-mv78460.dtsi
index 661d54c81580..0e24f1a38540 100644
--- a/arch/arm/boot/dts/armada-xp-mv78460.dtsi
+++ b/arch/arm/boot/dts/armada-xp-mv78460.dtsi
@@ -356,7 +356,7 @@
 			};
 
 			eth3: ethernet@34000 {
-				compatible = "marvell,armada-370-neta";
+				compatible = "marvell,armada-xp-neta";
 				reg = <0x34000 0x4000>;
 				interrupts = <14>;
 				clocks = <&gateclk 1>;
diff --git a/arch/arm/boot/dts/armada-xp.dtsi b/arch/arm/boot/dts/armada-xp.dtsi
index 013d63f69e36..8fdd6d7c0ab1 100644
--- a/arch/arm/boot/dts/armada-xp.dtsi
+++ b/arch/arm/boot/dts/armada-xp.dtsi
@@ -177,7 +177,7 @@
 			};
 
 			eth2: ethernet@30000 {
-				compatible = "marvell,armada-370-neta";
+				compatible = "marvell,armada-xp-neta";
 				reg = <0x30000 0x4000>;
 				interrupts = <12>;
 				clocks = <&gateclk 2>;
@@ -220,6 +220,14 @@
 				};
 			};
 
+			ethernet@70000 {
+				compatible = "marvell,armada-xp-neta";
+			};
+
+			ethernet@74000 {
+				compatible = "marvell,armada-xp-neta";
+			};
+
 			xor@f0900 {
 				compatible = "marvell,orion-xor";
 				reg = <0xF0900 0x100
-- 
2.1.4
