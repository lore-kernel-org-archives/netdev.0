From: Wolfram Sang <w.sang@pengutronix.de>
Subject: [RFC 2/3] arm: mxs: add enet_out clock to devicetree
Date: Tue, 29 Jan 2013 15:46:12 +0100
Message-ID: <1359470773-14290-3-git-send-email-w.sang@pengutronix.de>
References: <1359470773-14290-1-git-send-email-w.sang@pengutronix.de>
Cc: netdev@vger.kernel.org, Shawn Guo <shawn.guo@freescale.com>,
	Wolfram Sang <w.sang@pengutronix.de>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59043 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756644Ab3A2Oq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 09:46:28 -0500
In-Reply-To: <1359470773-14290-1-git-send-email-w.sang@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Put the clock to the devicetree, so the driver can take care of it
later. Then, we don't have to do the enabling as a workaround in board
init.

Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
---
 arch/arm/boot/dts/imx28-apf28.dts      |    3 +++
 arch/arm/boot/dts/imx28-apx4devkit.dts |    3 +++
 arch/arm/boot/dts/imx28-cfa10049.dts   |    3 +++
 arch/arm/boot/dts/imx28-evk.dts        |    3 +++
 arch/arm/boot/dts/imx28-sps1.dts       |    3 +++
 arch/arm/boot/dts/imx28-tx28.dts       |    3 +++
 6 files changed, 18 insertions(+)

diff --git a/arch/arm/boot/dts/imx28-apf28.dts b/arch/arm/boot/dts/imx28-apf28.dts
index 7eb0758..3047c0c 100644
--- a/arch/arm/boot/dts/imx28-apf28.dts
+++ b/arch/arm/boot/dts/imx28-apf28.dts
@@ -75,6 +75,9 @@
 
 	ahb@80080000 {
 		mac0: ethernet@800f0000 {
+			/* add enet_out clock */
+			clocks = <&clks 57>, <&clks 57>, <&clks 64>;
+			clock-names = "ipg", "ahb", "enet_out";
 			phy-mode = "rmii";
 			pinctrl-names = "default";
 			pinctrl-0 = <&mac0_pins_a>;
diff --git a/arch/arm/boot/dts/imx28-apx4devkit.dts b/arch/arm/boot/dts/imx28-apx4devkit.dts
index 5171667..b8c4b0c 100644
--- a/arch/arm/boot/dts/imx28-apx4devkit.dts
+++ b/arch/arm/boot/dts/imx28-apx4devkit.dts
@@ -159,6 +159,9 @@
 
 	ahb@80080000 {
 		mac0: ethernet@800f0000 {
+			/* add enet_out clock */
+			clocks = <&clks 57>, <&clks 57>, <&clks 64>;
+			clock-names = "ipg", "ahb", "enet_out";
 			phy-mode = "rmii";
 			pinctrl-names = "default";
 			pinctrl-0 = <&mac0_pins_a>;
diff --git a/arch/arm/boot/dts/imx28-cfa10049.dts b/arch/arm/boot/dts/imx28-cfa10049.dts
index bdc80a4..7204468 100644
--- a/arch/arm/boot/dts/imx28-cfa10049.dts
+++ b/arch/arm/boot/dts/imx28-cfa10049.dts
@@ -145,6 +145,9 @@
 
 	ahb@80080000 {
 		mac0: ethernet@800f0000 {
+			/* add enet_out clock */
+			clocks = <&clks 57>, <&clks 57>, <&clks 64>;
+			clock-names = "ipg", "ahb", "enet_out";
 			phy-mode = "rmii";
 			pinctrl-names = "default";
 			pinctrl-0 = <&mac0_pins_a>;
diff --git a/arch/arm/boot/dts/imx28-evk.dts b/arch/arm/boot/dts/imx28-evk.dts
index 2da316e..6634d71 100644
--- a/arch/arm/boot/dts/imx28-evk.dts
+++ b/arch/arm/boot/dts/imx28-evk.dts
@@ -224,6 +224,9 @@
 		};
 
 		mac0: ethernet@800f0000 {
+			/* add enet_out clock */
+			clocks = <&clks 57>, <&clks 57>, <&clks 64>;
+			clock-names = "ipg", "ahb", "enet_out";
 			phy-mode = "rmii";
 			pinctrl-names = "default";
 			pinctrl-0 = <&mac0_pins_a>;
diff --git a/arch/arm/boot/dts/imx28-sps1.dts b/arch/arm/boot/dts/imx28-sps1.dts
index e6cde8a..1df1859 100644
--- a/arch/arm/boot/dts/imx28-sps1.dts
+++ b/arch/arm/boot/dts/imx28-sps1.dts
@@ -112,6 +112,9 @@
 		};
 
 		mac0: ethernet@800f0000 {
+			/* add enet_out clock */
+			clocks = <&clks 57>, <&clks 57>, <&clks 64>;
+			clock-names = "ipg", "ahb", "enet_out";
 			phy-mode = "rmii";
 			pinctrl-names = "default";
 			pinctrl-0 = <&mac0_pins_a>;
diff --git a/arch/arm/boot/dts/imx28-tx28.dts b/arch/arm/boot/dts/imx28-tx28.dts
index 37be532..dcc90db 100644
--- a/arch/arm/boot/dts/imx28-tx28.dts
+++ b/arch/arm/boot/dts/imx28-tx28.dts
@@ -89,6 +89,9 @@
 
 	ahb@80080000 {
 		mac0: ethernet@800f0000 {
+			/* add enet_out clock */
+			clocks = <&clks 57>, <&clks 57>, <&clks 64>;
+			clock-names = "ipg", "ahb", "enet_out";
 			phy-mode = "rmii";
 			pinctrl-names = "default", "gpio_mode";
 			pinctrl-0 = <&mac0_pins_a>;
-- 
1.7.10.4
