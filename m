From: Jon Mason <jon.mason@broadcom.com>
Subject: [RFC 7/7] ARM: dts: NSP: Add bgmac entries
Date: Tue, 28 Jun 2016 15:34:44 -0400
Message-ID: <1467142484-11161-8-git-send-email-jon.mason@broadcom.com>
References: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, hauke@hauke-m.de,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: zajec5@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add device tree entries for the ethernet devices present on the
Broadcom Northstar Plus SoCs

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
---
 arch/arm/boot/dts/bcm-nsp.dtsi   | 16 ++++++++++++++++
 arch/arm/boot/dts/bcm958625k.dts |  8 ++++++++
 2 files changed, 24 insertions(+)

diff --git a/arch/arm/boot/dts/bcm-nsp.dtsi b/arch/arm/boot/dts/bcm-nsp.dtsi
index def9e78..9b4e45e 100644
--- a/arch/arm/boot/dts/bcm-nsp.dtsi
+++ b/arch/arm/boot/dts/bcm-nsp.dtsi
@@ -192,6 +192,22 @@
 			status = "disabled";
 		};
 
+		gmac0: enet@22000 {
+			compatible = "brcm,bgmac-enet";
+			reg = <0x022000 0x1000>,
+			      <0x110000 0x1000>;
+			interrupts = <GIC_SPI 147 IRQ_TYPE_LEVEL_HIGH>;
+			status = "disabled";
+		};
+
+		gmac1: enet@23000 {
+			compatible = "brcm,bgmac-enet";
+			reg = <0x023000 0x1000>,
+			      <0x111000 0x1000>;
+			interrupts = <GIC_SPI 148 IRQ_TYPE_LEVEL_HIGH>;
+			status = "disabled";
+		};
+
 		nand: nand@26000 {
 			compatible = "brcm,nand-iproc", "brcm,brcmnand-v6.1";
 			reg = <0x026000 0x600>,
diff --git a/arch/arm/boot/dts/bcm958625k.dts b/arch/arm/boot/dts/bcm958625k.dts
index e298450..d16ab53 100644
--- a/arch/arm/boot/dts/bcm958625k.dts
+++ b/arch/arm/boot/dts/bcm958625k.dts
@@ -56,6 +56,14 @@
 	status = "okay";
 };
 
+&gmac0 {
+	status = "okay";
+};
+
+&gmac1 {
+	status = "okay";
+};
+
 &pcie0 {
 	status = "okay";
 };
-- 
1.9.1
