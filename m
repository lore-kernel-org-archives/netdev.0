From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 15/15] ARM: dts: am335x/am437x/dra7: use new "ti,cpsw-mdio" compat string
Date: Fri, 24 Jun 2016 21:23:55 +0300
Message-ID: <20160624182355.23515-16-grygorii.strashko@ti.com>
References: <20160624182355.23515-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, <devicetree@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:36614 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbcFXSYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 14:24:30 -0400
In-Reply-To: <20160624182355.23515-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add "ti,cpsw-mdio" for am335x/am437x/dra7 SoCs where MDIO is
implemented as part of TI CPSW and, this way, enable PM runtime auto
suspend for Davinci MDIO driver on these paltforms.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 arch/arm/boot/dts/am33xx.dtsi | 2 +-
 arch/arm/boot/dts/am4372.dtsi | 2 +-
 arch/arm/boot/dts/dra7.dtsi   | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index 52be48b..7fa9a1d 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -789,7 +789,7 @@
 			status = "disabled";
 
 			davinci_mdio: mdio@4a101000 {
-				compatible = "ti,davinci_mdio";
+				compatible = "ti,cpsw-mdio","ti,davinci_mdio";
 				#address-cells = <1>;
 				#size-cells = <0>;
 				ti,hwmods = "davinci_mdio";
diff --git a/arch/arm/boot/dts/am4372.dtsi b/arch/arm/boot/dts/am4372.dtsi
index 12fcde4..ea76fa7 100644
--- a/arch/arm/boot/dts/am4372.dtsi
+++ b/arch/arm/boot/dts/am4372.dtsi
@@ -636,7 +636,7 @@
 			syscon = <&scm_conf>;
 
 			davinci_mdio: mdio@4a101000 {
-				compatible = "ti,am4372-mdio","ti,davinci_mdio";
+				compatible = "ti,am4372-mdio","ti,cpsw-mdio","ti,davinci_mdio";
 				reg = <0x4a101000 0x100>;
 				#address-cells = <1>;
 				#size-cells = <0>;
diff --git a/arch/arm/boot/dts/dra7.dtsi b/arch/arm/boot/dts/dra7.dtsi
index 3a8f397..8275d2e 100644
--- a/arch/arm/boot/dts/dra7.dtsi
+++ b/arch/arm/boot/dts/dra7.dtsi
@@ -1663,7 +1663,7 @@
 			status = "disabled";
 
 			davinci_mdio: mdio@48485000 {
-				compatible = "ti,davinci_mdio";
+				compatible = "ti,cpsw-mdio","ti,davinci_mdio";
 				#address-cells = <1>;
 				#size-cells = <0>;
 				ti,hwmods = "davinci_mdio";
-- 
2.9.0
