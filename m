From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH RFC 3/5] ARM: dts: sun8i-h3: Add H3 Ethernet PHY device node to sun8i-h3.dtsi
Date: Tue,  5 Apr 2016 00:22:32 +0800
Message-ID: <1459786954-12649-4-git-send-email-wens@csie.org>
References: <1459786954-12649-1-git-send-email-wens@csie.org>
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1459786954-12649-1-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The Allwinner H3 SoC incorporates an Ethernet PHY, whose controls are
mapped to a system control register.

Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
---
 arch/arm/boot/dts/sun8i-h3.dtsi | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/arch/arm/boot/dts/sun8i-h3.dtsi b/arch/arm/boot/dts/sun8i-h3.dtsi
index 4a4926b0b0ed..9a28aeba9bc6 100644
--- a/arch/arm/boot/dts/sun8i-h3.dtsi
+++ b/arch/arm/boot/dts/sun8i-h3.dtsi
@@ -323,6 +323,15 @@
 		#size-cells = <1>;
 		ranges;
 
+		ephy: ethernet-phy@01c00030 {
+			compatible = "allwinner,sun8i-h3-ephy";
+			reg = <0x01c00030 0x4>;
+			clocks = <&bus_gates 128>;
+			resets = <&ahb_rst 66>;
+			#clock-cells = <0>;
+			clock-output-names = "emac_tx";
+		};
+
 		dma: dma-controller@01c02000 {
 			compatible = "allwinner,sun8i-h3-dma";
 			reg = <0x01c02000 0x1000>;
-- 
2.7.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
