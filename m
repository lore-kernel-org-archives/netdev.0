From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net v1 1/2] ARM: dts: imx: let's name the ptp interrupt for the fec ethernet driver
Date: Mon,  2 Oct 2017 17:04:41 -0700
Message-ID: <20171003000442.31841-1-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@nxp.com, lznuaa@gmail.com,
        Troy Kisky <troy.kisky@boundarydevices.com>
To: shawn.guo@linaro.org, fugang.duan@nxp.com, netdev@vger.kernel.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wsip-98-189-142-135.oc.oc.cox.net ([98.189.142.135]:49514 "EHLO
        office-server2" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750869AbdJCAEu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 20:04:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

imx7s/imx7d has the ptp interrupt newly added as well.
This will allow the ptp interrupt to have its own interrupt routine.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 arch/arm/boot/dts/imx6qdl.dtsi | 1 +
 arch/arm/boot/dts/imx6sx.dtsi  | 2 ++
 arch/arm/boot/dts/imx6ul.dtsi  | 2 ++
 arch/arm/boot/dts/imx7d.dtsi   | 4 +++-
 arch/arm/boot/dts/imx7s.dtsi   | 4 +++-
 5 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/imx6qdl.dtsi b/arch/arm/boot/dts/imx6qdl.dtsi
index 8884b4a3cafb..d848d2bfe8e2 100644
--- a/arch/arm/boot/dts/imx6qdl.dtsi
+++ b/arch/arm/boot/dts/imx6qdl.dtsi
@@ -1017,6 +1017,7 @@
 			fec: ethernet@02188000 {
 				compatible = "fsl,imx6q-fec";
 				reg = <0x02188000 0x4000>;
+				interrupt-names = "","ptp";
 				interrupts-extended =
 					<&intc 0 118 IRQ_TYPE_LEVEL_HIGH>,
 					<&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
diff --git a/arch/arm/boot/dts/imx6sx.dtsi b/arch/arm/boot/dts/imx6sx.dtsi
index 6c7eb54be9e2..d64ae33c0b41 100644
--- a/arch/arm/boot/dts/imx6sx.dtsi
+++ b/arch/arm/boot/dts/imx6sx.dtsi
@@ -861,6 +861,7 @@
 			fec1: ethernet@02188000 {
 				compatible = "fsl,imx6sx-fec", "fsl,imx6q-fec";
 				reg = <0x02188000 0x4000>;
+				interrupt-names = "","ptp";
 				interrupts = <GIC_SPI 118 IRQ_TYPE_LEVEL_HIGH>,
 					     <GIC_SPI 119 IRQ_TYPE_LEVEL_HIGH>;
 				clocks = <&clks IMX6SX_CLK_ENET>,
@@ -970,6 +971,7 @@
 			fec2: ethernet@021b4000 {
 				compatible = "fsl,imx6sx-fec", "fsl,imx6q-fec";
 				reg = <0x021b4000 0x4000>;
+				interrupt-names = "","ptp";
 				interrupts = <GIC_SPI 102 IRQ_TYPE_LEVEL_HIGH>,
 					     <GIC_SPI 103 IRQ_TYPE_LEVEL_HIGH>;
 				clocks = <&clks IMX6SX_CLK_ENET>,
diff --git a/arch/arm/boot/dts/imx6ul.dtsi b/arch/arm/boot/dts/imx6ul.dtsi
index f11a241a340d..fe093f8531b0 100644
--- a/arch/arm/boot/dts/imx6ul.dtsi
+++ b/arch/arm/boot/dts/imx6ul.dtsi
@@ -476,6 +476,7 @@
 			fec2: ethernet@020b4000 {
 				compatible = "fsl,imx6ul-fec", "fsl,imx6q-fec";
 				reg = <0x020b4000 0x4000>;
+				interrupt-names = "","ptp";
 				interrupts = <GIC_SPI 120 IRQ_TYPE_LEVEL_HIGH>,
 					     <GIC_SPI 121 IRQ_TYPE_LEVEL_HIGH>;
 				clocks = <&clks IMX6UL_CLK_ENET>,
@@ -775,6 +776,7 @@
 			fec1: ethernet@02188000 {
 				compatible = "fsl,imx6ul-fec", "fsl,imx6q-fec";
 				reg = <0x02188000 0x4000>;
+				interrupt-names = "","ptp";
 				interrupts = <GIC_SPI 118 IRQ_TYPE_LEVEL_HIGH>,
 					     <GIC_SPI 119 IRQ_TYPE_LEVEL_HIGH>;
 				clocks = <&clks IMX6UL_CLK_ENET>,
diff --git a/arch/arm/boot/dts/imx7d.dtsi b/arch/arm/boot/dts/imx7d.dtsi
index f46814a7ea44..e8fc76483236 100644
--- a/arch/arm/boot/dts/imx7d.dtsi
+++ b/arch/arm/boot/dts/imx7d.dtsi
@@ -114,9 +114,11 @@
 	fec2: ethernet@30bf0000 {
 		compatible = "fsl,imx7d-fec", "fsl,imx6sx-fec";
 		reg = <0x30bf0000 0x10000>;
+		interrupt-names = "","","","ptp";
 		interrupts = <GIC_SPI 100 IRQ_TYPE_LEVEL_HIGH>,
 			<GIC_SPI 101 IRQ_TYPE_LEVEL_HIGH>,
-			<GIC_SPI 102 IRQ_TYPE_LEVEL_HIGH>;
+			<GIC_SPI 102 IRQ_TYPE_LEVEL_HIGH>,
+			<GIC_SPI 103 IRQ_TYPE_LEVEL_HIGH>;
 		clocks = <&clks IMX7D_ENET_AXI_ROOT_CLK>,
 			<&clks IMX7D_ENET_AXI_ROOT_CLK>,
 			<&clks IMX7D_ENET2_TIME_ROOT_CLK>,
diff --git a/arch/arm/boot/dts/imx7s.dtsi b/arch/arm/boot/dts/imx7s.dtsi
index 82ad26e766eb..fc1376079494 100644
--- a/arch/arm/boot/dts/imx7s.dtsi
+++ b/arch/arm/boot/dts/imx7s.dtsi
@@ -1007,9 +1007,11 @@
 			fec1: ethernet@30be0000 {
 				compatible = "fsl,imx7d-fec", "fsl,imx6sx-fec";
 				reg = <0x30be0000 0x10000>;
+				interrupt-names = "","","","ptp";
 				interrupts = <GIC_SPI 118 IRQ_TYPE_LEVEL_HIGH>,
 					<GIC_SPI 119 IRQ_TYPE_LEVEL_HIGH>,
-					<GIC_SPI 120 IRQ_TYPE_LEVEL_HIGH>;
+					<GIC_SPI 120 IRQ_TYPE_LEVEL_HIGH>,
+					<GIC_SPI 121 IRQ_TYPE_LEVEL_HIGH>;
 				clocks = <&clks IMX7D_ENET_AXI_ROOT_CLK>,
 					<&clks IMX7D_ENET_AXI_ROOT_CLK>,
 					<&clks IMX7D_ENET1_TIME_ROOT_CLK>,
-- 
2.11.0
