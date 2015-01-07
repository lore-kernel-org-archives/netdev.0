From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH net-next 2/2] Revert "ARM: dts: imx6qdl: enable FEC magic-packet feature"
Date: Wed,  7 Jan 2015 10:39:53 -0200
Message-ID: <1420634393-30027-2-git-send-email-festevam@gmail.com>
References: <1420634393-30027-1-git-send-email-festevam@gmail.com>
Cc: shawn.guo@linaro.org, fugang.duan@freescale.com,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:33930 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbbAGMkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 07:40:41 -0500
Received: by mail-vc0-f182.google.com with SMTP id hq12so414342vcb.41
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 04:40:40 -0800 (PST)
In-Reply-To: <1420634393-30027-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

As 456062b3ec6f ("ARM: imx: add FEC sleep mode callback function") has been
reverted, also revert the dts part.

This reverts commit 07b4d2dda0c00f56248 ("ARM: dts: imx6qdl: enable FEC 
magic-packet feature").

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 arch/arm/boot/dts/imx6qdl-sabreauto.dtsi | 1 -
 arch/arm/boot/dts/imx6qdl-sabresd.dtsi   | 1 -
 2 files changed, 2 deletions(-)

diff --git a/arch/arm/boot/dts/imx6qdl-sabreauto.dtsi b/arch/arm/boot/dts/imx6qdl-sabreauto.dtsi
index 327d362f..009abd6 100644
--- a/arch/arm/boot/dts/imx6qdl-sabreauto.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-sabreauto.dtsi
@@ -67,7 +67,6 @@
 	phy-mode = "rgmii";
 	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
 			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
-	fsl,magic-packet;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/imx6qdl-sabresd.dtsi b/arch/arm/boot/dts/imx6qdl-sabresd.dtsi
index 6bfd0bc..f1cd214 100644
--- a/arch/arm/boot/dts/imx6qdl-sabresd.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-sabresd.dtsi
@@ -160,7 +160,6 @@
 	pinctrl-0 = <&pinctrl_enet>;
 	phy-mode = "rgmii";
 	phy-reset-gpios = <&gpio1 25 0>;
-	fsl,magic-packet;
 	status = "okay";
 };
 
-- 
1.9.1
