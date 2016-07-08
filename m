From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 2/2] ARM: dts: NSP: Add BCM958625HR switch ports
Date: Fri,  8 Jul 2016 11:49:29 -0700
Message-ID: <1468003769-26959-3-git-send-email-f.fainelli@gmail.com>
References: <1468003769-26959-1-git-send-email-f.fainelli@gmail.com>
Cc: devicetree@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com,
	jon.mason@broadcom.com, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	linux-arm-kernel@lists.infradead.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34345 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756248AbcGHStf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 14:49:35 -0400
In-Reply-To: <1468003769-26959-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the layout of the switch ports found on the BCM958625HR reference
board. The CPU port is hooked up to the AMAC0 Ethernet controlelr
adapter, so we also enable it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 arch/arm/boot/dts/bcm958625hr.dts | 49 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)

diff --git a/arch/arm/boot/dts/bcm958625hr.dts b/arch/arm/boot/dts/bcm958625hr.dts
index 03b8bbeb694f..4239e58cf97f 100644
--- a/arch/arm/boot/dts/bcm958625hr.dts
+++ b/arch/arm/boot/dts/bcm958625hr.dts
@@ -109,3 +109,52 @@
 		groups = "nand_grp";
 	};
 };
+
+&amac0 {
+	status = "okay";
+};
+
+&srab {
+	compatible = "brcm,bcm58625-srab", "brcm,nsp-srab";
+	status = "okay";
+
+	ports {
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		port@0 {
+			label = "port0";
+			reg = <0>;
+		};
+
+		port@1 {
+			label = "port1";
+			reg = <1>;
+		};
+
+		port@2 {
+			label = "port2";
+			reg = <2>;
+		};
+
+		port@3 {
+			label = "port3";
+			reg = <3>;
+		};
+
+		port@4 {
+			label = "port4";
+			reg = <4>;
+		};
+
+		port@5 {
+			ethernet = <&amac0>;
+			label = "cpu";
+			reg = <5>;
+			fixed-link {
+				speed = <1000>;
+				full-duplex;
+			};
+		};
+	};
+};
-- 
2.7.4
