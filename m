From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH v2 5/5] ARM: dts: am33xx: adopt to cpsw changes
Date: Fri, 23 Aug 2013 10:43:37 +0200
Message-ID: <1377247417-27386-6-git-send-email-zonque@gmail.com>
References: <1377247417-27386-1-git-send-email-zonque@gmail.com>
Cc: nsekhar@ti.com, sergei.shtylyov@cogentembedded.com,
	davem@davemloft.net, ujhelyi.m@gmail.com, mugunthanvnm@ti.com,
	vaibhav.bedia@ti.com, d-gerlach@ti.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org, Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:47713 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755038Ab3HWIns (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 04:43:48 -0400
In-Reply-To: <1377247417-27386-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This third memory region just denotes one single register in the CONTROL
module block. The driver uses that in order to set the correct physical
ethernet interface modes.

Also update the compatible string to make use of the am335x specific
features of the cpsw driver.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 arch/arm/boot/dts/am33xx.dtsi | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index a785b95..1a1e9dd 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -446,7 +446,7 @@
 		};
 
 		mac: ethernet@4a100000 {
-			compatible = "ti,cpsw";
+			compatible = "ti,am3352-cpsw";
 			ti,hwmods = "cpgmac0";
 			cpdma_channels = <8>;
 			ale_entries = <1024>;
@@ -459,7 +459,8 @@
 			cpts_clock_mult = <0x80000000>;
 			cpts_clock_shift = <29>;
 			reg = <0x4a100000 0x800
-			       0x4a101200 0x100>;
+			       0x4a101200 0x100
+			       0x44e10650 0x4>;
 			#address-cells = <1>;
 			#size-cells = <1>;
 			interrupt-parent = <&intc>;
-- 
1.8.3.1
