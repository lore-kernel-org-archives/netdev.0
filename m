From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 3/3] ARM: sunxi: dt: Convert to the new net compatibles
Date: Sun,  2 Feb 2014 14:49:13 +0100
Message-ID: <1391348953-10662-3-git-send-email-maxime.ripard@free-electrons.com>
References: <1391348953-10662-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:49893 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751566AbaBCIaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 03:30:08 -0500
In-Reply-To: <1391348953-10662-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch the device tree to the new compatibles introduced in the ethernet and
mdio drivers to have a common pattern accross all Allwinner SoCs.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 arch/arm/boot/dts/sun4i-a10.dtsi  | 4 ++--
 arch/arm/boot/dts/sun5i-a10s.dtsi | 4 ++--
 arch/arm/boot/dts/sun7i-a20.dtsi  | 4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/arm/boot/dts/sun4i-a10.dtsi b/arch/arm/boot/dts/sun4i-a10.dtsi
index 040bb0e..10666ca 100644
--- a/arch/arm/boot/dts/sun4i-a10.dtsi
+++ b/arch/arm/boot/dts/sun4i-a10.dtsi
@@ -315,7 +315,7 @@
 		ranges;
 
 		emac: ethernet@01c0b000 {
-			compatible = "allwinner,sun4i-emac";
+			compatible = "allwinner,sun4i-a10-emac";
 			reg = <0x01c0b000 0x1000>;
 			interrupts = <55>;
 			clocks = <&ahb_gates 17>;
@@ -323,7 +323,7 @@
 		};
 
 		mdio@01c0b080 {
-			compatible = "allwinner,sun4i-mdio";
+			compatible = "allwinner,sun4i-a10-mdio";
 			reg = <0x01c0b080 0x14>;
 			status = "disabled";
 			#address-cells = <1>;
diff --git a/arch/arm/boot/dts/sun5i-a10s.dtsi b/arch/arm/boot/dts/sun5i-a10s.dtsi
index ea16054..6496159 100644
--- a/arch/arm/boot/dts/sun5i-a10s.dtsi
+++ b/arch/arm/boot/dts/sun5i-a10s.dtsi
@@ -278,7 +278,7 @@
 		ranges;
 
 		emac: ethernet@01c0b000 {
-			compatible = "allwinner,sun4i-emac";
+			compatible = "allwinner,sun4i-a10-emac";
 			reg = <0x01c0b000 0x1000>;
 			interrupts = <55>;
 			clocks = <&ahb_gates 17>;
@@ -286,7 +286,7 @@
 		};
 
 		mdio@01c0b080 {
-			compatible = "allwinner,sun4i-mdio";
+			compatible = "allwinner,sun4i-a10-mdio";
 			reg = <0x01c0b080 0x14>;
 			status = "disabled";
 			#address-cells = <1>;
diff --git a/arch/arm/boot/dts/sun7i-a20.dtsi b/arch/arm/boot/dts/sun7i-a20.dtsi
index 119f066..9ff0948 100644
--- a/arch/arm/boot/dts/sun7i-a20.dtsi
+++ b/arch/arm/boot/dts/sun7i-a20.dtsi
@@ -340,7 +340,7 @@
 		ranges;
 
 		emac: ethernet@01c0b000 {
-			compatible = "allwinner,sun4i-emac";
+			compatible = "allwinner,sun4i-a10-emac";
 			reg = <0x01c0b000 0x1000>;
 			interrupts = <0 55 4>;
 			clocks = <&ahb_gates 17>;
@@ -348,7 +348,7 @@
 		};
 
 		mdio@01c0b080 {
-			compatible = "allwinner,sun4i-mdio";
+			compatible = "allwinner,sun4i-a10-mdio";
 			reg = <0x01c0b080 0x14>;
 			status = "disabled";
 			#address-cells = <1>;
-- 
1.8.4.2
