From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v4 04/10] ARM: dts: sun8i-h3: Add dt node for the syscon control module
Date: Fri,  7 Oct 2016 10:25:51 +0200
Message-ID: <1475828757-926-5-git-send-email-clabbe.montjoie@gmail.com>
References: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, davem@davemloft.net, f.fainelli@gmail.com,
        andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33260 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756315AbcJGI22 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 04:28:28 -0400
In-Reply-To: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add the dt node for the syscon register present on the
Allwinner H3.

Only two register are present in this syscon and the only one useful is
the one dedicated to EMAC clock.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm/boot/dts/sun8i-h3.dtsi | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/arm/boot/dts/sun8i-h3.dtsi b/arch/arm/boot/dts/sun8i-h3.dtsi
index 8a95e36..1101d2f 100644
--- a/arch/arm/boot/dts/sun8i-h3.dtsi
+++ b/arch/arm/boot/dts/sun8i-h3.dtsi
@@ -140,6 +140,11 @@
 		#size-cells = <1>;
 		ranges;
 
+		syscon: syscon@01c00000 {
+			compatible = "syscon";
+			reg = <0x01c00000 0x1000>;
+		};
+
 		dma: dma-controller@01c02000 {
 			compatible = "allwinner,sun8i-h3-dma";
 			reg = <0x01c02000 0x1000>;
-- 
2.7.3
