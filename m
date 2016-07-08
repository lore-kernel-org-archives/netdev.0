From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH 7/7] ARM: dts: NSP: Add bgmac entries
Date: Fri,  8 Jul 2016 11:56:02 -0400
Message-ID: <1467993362-13229-1-git-send-email-jon.mason@broadcom.com>
Cc: zajec5@gmail.com, hauke@hauke-m.de,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, Ray Jui <rjui@broadcom.com>,
	Scott Branden <sbranden@broadcom.com>,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add device tree entries for the ethernet devices present on the
Broadcom Northstar Plus SoCs

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
---
 arch/arm/boot/dts/bcm-nsp.dtsi   | 18 ++++++++++++++++++
 arch/arm/boot/dts/bcm958625k.dts |  8 ++++++++
 2 files changed, 26 insertions(+)

diff --git a/arch/arm/boot/dts/bcm-nsp.dtsi b/arch/arm/boot/dts/bcm-nsp.dtsi
index def9e78..f6d5abe 100644
--- a/arch/arm/boot/dts/bcm-nsp.dtsi
+++ b/arch/arm/boot/dts/bcm-nsp.dtsi
@@ -192,6 +192,24 @@
 			status = "disabled";
 		};
 
+		amac0: ethernet@22000 {
+			compatible = "brcm,nsp-amac";
+			reg = <0x022000 0x1000>,
+			      <0x110000 0x1000>;
+			reg-names = "amac_base", "idm_base";
+			interrupts = <GIC_SPI 147 IRQ_TYPE_LEVEL_HIGH>;
+			status = "disabled";
+		};
+
+		amac1: ethernet@23000 {
+			compatible = "brcm,nsp-amac";
+			reg = <0x023000 0x1000>,
+			      <0x111000 0x1000>;
+			reg-names = "amac_base", "idm_base";
+			interrupts = <GIC_SPI 148 IRQ_TYPE_LEVEL_HIGH>;
+			status = "disabled";
+		};
+
 		nand: nand@26000 {
 			compatible = "brcm,nand-iproc", "brcm,brcmnand-v6.1";
 			reg = <0x026000 0x600>,
diff --git a/arch/arm/boot/dts/bcm958625k.dts b/arch/arm/boot/dts/bcm958625k.dts
index e298450..f41a13b 100644
--- a/arch/arm/boot/dts/bcm958625k.dts
+++ b/arch/arm/boot/dts/bcm958625k.dts
@@ -56,6 +56,14 @@
 	status = "okay";
 };
 
+&amac0 {
+	status = "okay";
+};
+
+&amac1 {
+	status = "okay";
+};
+
 &pcie0 {
 	status = "okay";
 };
-- 
1.9.1
