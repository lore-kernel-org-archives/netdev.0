From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH 2/2] ARM: dts: imx6: tag boards that have the HW workaround for ERR006687
Date: Wed,  1 Jun 2016 17:29:43 +0200
Message-ID: <1464794983-31484-3-git-send-email-l.stach@pengutronix.de>
References: <1464794983-31484-1-git-send-email-l.stach@pengutronix.de>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, kernel@pengutronix.de,
	patchwork-lst@pengutronix.de
To: Shawn Guo <shawnguo@kernel.org>, Fugang Duan <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:42411 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932597AbcFAP3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 11:29:51 -0400
In-Reply-To: <1464794983-31484-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the DT property to all boards that have the hardware workaround
for erratum ERR006687 present. This allows the CPUidle driver to use
the deep idle states, even if the FEC is active.

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 arch/arm/boot/dts/imx6dl-riotboard.dts       | 1 +
 arch/arm/boot/dts/imx6q-arm2.dts             | 1 +
 arch/arm/boot/dts/imx6qdl-nit6xlite.dtsi     | 1 +
 arch/arm/boot/dts/imx6qdl-nitrogen6_max.dtsi | 1 +
 arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi    | 1 +
 arch/arm/boot/dts/imx6qdl-sabreauto.dtsi     | 1 +
 arch/arm/boot/dts/imx6qdl-sabrelite.dtsi     | 1 +
 arch/arm/boot/dts/imx6qdl-wandboard.dtsi     | 1 +
 8 files changed, 8 insertions(+)

diff --git a/arch/arm/boot/dts/imx6dl-riotboard.dts b/arch/arm/boot/dts/imx6dl-riotboard.dts
index bfbed52ce1bd..b10dc9513c6b 100644
--- a/arch/arm/boot/dts/imx6dl-riotboard.dts
+++ b/arch/arm/boot/dts/imx6dl-riotboard.dts
@@ -97,6 +97,7 @@
 	phy-reset-gpios = <&gpio3 31 0>;
 	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
 			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
+	fsl,err006687-war-present;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/imx6q-arm2.dts b/arch/arm/boot/dts/imx6q-arm2.dts
index d6515f7a56c4..fce60ef991ce 100644
--- a/arch/arm/boot/dts/imx6q-arm2.dts
+++ b/arch/arm/boot/dts/imx6q-arm2.dts
@@ -185,6 +185,7 @@
 	phy-mode = "rgmii";
 	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
 			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
+	fsl,err006687-war-present;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/imx6qdl-nit6xlite.dtsi b/arch/arm/boot/dts/imx6qdl-nit6xlite.dtsi
index e456b5cc1b03..a74f396965ca 100644
--- a/arch/arm/boot/dts/imx6qdl-nit6xlite.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-nit6xlite.dtsi
@@ -250,6 +250,7 @@
 	txd3-skew-ps = <0>;
 	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
 			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
+	fsl,err006687-war-present;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/imx6qdl-nitrogen6_max.dtsi b/arch/arm/boot/dts/imx6qdl-nitrogen6_max.dtsi
index 657da6b6ccd2..da76a128e5a9 100644
--- a/arch/arm/boot/dts/imx6qdl-nitrogen6_max.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-nitrogen6_max.dtsi
@@ -385,6 +385,7 @@
 	txd3-skew-ps = <0>;
 	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
 			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
+	fsl,err006687-war-present;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi b/arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi
index 73915db704a0..dfcb5001a126 100644
--- a/arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi
@@ -287,6 +287,7 @@
 	txd3-skew-ps = <0>;
 	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
 			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
+	fsl,err006687-war-present;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/imx6qdl-sabreauto.dtsi b/arch/arm/boot/dts/imx6qdl-sabreauto.dtsi
index d354d406954d..e250da2a4caa 100644
--- a/arch/arm/boot/dts/imx6qdl-sabreauto.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-sabreauto.dtsi
@@ -155,6 +155,7 @@
 	phy-mode = "rgmii";
 	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
 			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
+	fsl,err006687-war-present;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/imx6qdl-sabrelite.dtsi b/arch/arm/boot/dts/imx6qdl-sabrelite.dtsi
index c47fe6c79b36..d451ca242751 100644
--- a/arch/arm/boot/dts/imx6qdl-sabrelite.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-sabrelite.dtsi
@@ -273,6 +273,7 @@
 	txd3-skew-ps = <0>;
 	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
 			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
+	fsl,err006687-war-present;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/imx6qdl-wandboard.dtsi b/arch/arm/boot/dts/imx6qdl-wandboard.dtsi
index 8e7c40e114dd..684c6a776565 100644
--- a/arch/arm/boot/dts/imx6qdl-wandboard.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-wandboard.dtsi
@@ -211,6 +211,7 @@
 	phy-reset-gpios = <&gpio3 29 0>;
 	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
 			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
+	fsl,err006687-war-present;
 	status = "okay";
 };
 
-- 
2.8.1
