From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH net-next v1 3/3] ARM: dts: imx6qdl: enable FEC magic-packet feature
Date: Wed, 24 Dec 2014 17:30:41 +0800
Message-ID: <1419413441-3406-4-git-send-email-b38611@freescale.com>
References: <1419413441-3406-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <b38611@freescale.com>
To: <shawn.guo@linaro.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0108.outbound.protection.outlook.com ([157.56.111.108]:51168
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751650AbaLXKUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Dec 2014 05:20:49 -0500
In-Reply-To: <1419413441-3406-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add FEC magic-packet feature support.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 arch/arm/boot/dts/imx6qdl-sabreauto.dtsi |    1 +
 arch/arm/boot/dts/imx6qdl-sabresd.dtsi   |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/arch/arm/boot/dts/imx6qdl-sabreauto.dtsi b/arch/arm/boot/dts/imx6qdl-sabreauto.dtsi
index 009abd6..327d362 100644
--- a/arch/arm/boot/dts/imx6qdl-sabreauto.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-sabreauto.dtsi
@@ -67,6 +67,7 @@
 	phy-mode = "rgmii";
 	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
 			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
+	fsl,magic-packet;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/imx6qdl-sabresd.dtsi b/arch/arm/boot/dts/imx6qdl-sabresd.dtsi
index f1cd214..6bfd0bc 100644
--- a/arch/arm/boot/dts/imx6qdl-sabresd.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-sabresd.dtsi
@@ -160,6 +160,7 @@
 	pinctrl-0 = <&pinctrl_enet>;
 	phy-mode = "rgmii";
 	phy-reset-gpios = <&gpio1 25 0>;
+	fsl,magic-packet;
 	status = "okay";
 };
 
-- 
1.7.8
