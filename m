From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v5 12/20] arm: sun8i: orangepi-pc-plus: Set EMAC activity LEDs to active high
Date: Mon,  1 May 2017 14:45:12 +0200
Message-ID: <20170501124520.3769-13-clabbe.montjoie@gmail.com>
References: <20170501124520.3769-1-clabbe.montjoie@gmail.com>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36055 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424764AbdEAMsU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 08:48:20 -0400
In-Reply-To: <20170501124520.3769-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the Orange Pi PC Plus, the polarity of the LEDs on the RJ45 Ethernet
port were changed from active low to active high.

Signed-off-by: Chen-Yu Tsai <wens@csie.org>
Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts b/arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts
index 8b93f5c..a10281b 100644
--- a/arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts
+++ b/arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts
@@ -53,6 +53,11 @@
 	};
 };
 
+&emac {
+	/* LEDs changed to active high on the plus */
+	/delete-property/ allwinner,leds-active-low;
+};
+
 &mmc1 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&mmc1_pins_a>;
-- 
2.10.2
