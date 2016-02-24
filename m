From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: [v2, 1/3] ARM: dts: ls1021a: add 1588 timer node
Date: Wed, 24 Feb 2016 17:26:54 +0800
Message-ID: <1456306016-29723-2-git-send-email-yangbo.lu@nxp.com>
References: <1456306016-29723-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <robh+dt@kernel.org>,
	Andy Fleming <afleming@gmail.com>,
	Kumar Gala <galak@codeaurora.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Yangbo Lu <yangbo.lu@nxp.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0056.outbound.protection.outlook.com ([157.56.110.56]:24832
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751718AbcBXJvU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 04:51:20 -0500
In-Reply-To: <1456306016-29723-1-git-send-email-yangbo.lu@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the 1588 timer node for ls1021a platform to
support gianfar ptp driver.

Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
---
Changes for v2:
	- Modified commit message
---
 arch/arm/boot/dts/ls1021a.dtsi | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/arch/arm/boot/dts/ls1021a.dtsi b/arch/arm/boot/dts/ls1021a.dtsi
index 2c84ca2..ecf12dc 100644
--- a/arch/arm/boot/dts/ls1021a.dtsi
+++ b/arch/arm/boot/dts/ls1021a.dtsi
@@ -457,6 +457,18 @@
 			reg = <0x0 0x2d24000 0x0 0x4000>;
 		};
 
+		ptp_clock@2d10e00 {
+			compatible = "fsl,etsec-ptp";
+			reg = <0x0 0x2d10e00 0x0 0xb0>;
+			interrupts = <GIC_SPI 173 IRQ_TYPE_LEVEL_HIGH>;
+			fsl,tclk-period = <5>;
+			fsl,tmr-prsc    = <2>;
+			fsl,tmr-add     = <0xaaaaaaab>;
+			fsl,tmr-fiper1  = <999999990>;
+			fsl,tmr-fiper2  = <99990>;
+			fsl,max-adj     = <499999999>;
+		};
+
 		enet0: ethernet@2d10000 {
 			compatible = "fsl,etsec2";
 			device_type = "network";
-- 
2.1.0.27.g96db324
