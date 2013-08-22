From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 4/4] ARM: dts: am33xx: add third memory region to cpsw block
Date: Thu, 22 Aug 2013 13:37:28 +0200
Message-ID: <1377171448-27924-5-git-send-email-zonque@gmail.com>
References: <1377171448-27924-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, ujhelyi.m@gmail.com, mugunthanvnm@ti.com,
	vaibhav.bedia@ti.com, d-gerlach@ti.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org, Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:46157 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753031Ab3HVLhi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 07:37:38 -0400
In-Reply-To: <1377171448-27924-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This third memory region just denotes one single register in the CONTROL
module block. The driver uses that in order to set the correct physical
ethernet interface modes.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 arch/arm/boot/dts/am33xx.dtsi | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index a785b95..4ac4e4c 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
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
