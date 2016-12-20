From: Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Subject: [PATCH 2/2] ARM: dts: hix5hd2: don't change the existing compatible string
Date: Tue, 20 Dec 2016 10:09:29 +0800
Message-ID: <1482199769-106501-3-git-send-email-lidongpo@hisilicon.com>
References: <1482199769-106501-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xuejiancheng-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <benjamin.chenhao-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
        <caizhiyong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
To: <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>, <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>,
        <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1482199769-106501-1-git-send-email-lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The SoC hix5hd2 compatible string has the suffix "-gmac" and
we should not change it.
We should only add the generic compatible string "hisi-gmac-v1".

Fixes: 0855950ba580 ("ARM: dts: hix5hd2: add gmac generic compatible and clock names")
Signed-off-by: Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
---
 arch/arm/boot/dts/hisi-x5hd2.dtsi | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/hisi-x5hd2.dtsi b/arch/arm/boot/dts/hisi-x5hd2.dtsi
index 0da76c5..2d06f4c 100644
--- a/arch/arm/boot/dts/hisi-x5hd2.dtsi
+++ b/arch/arm/boot/dts/hisi-x5hd2.dtsi
@@ -436,7 +436,7 @@
 		};
 
 		gmac0: ethernet@1840000 {
-			compatible = "hisilicon,hix5hd2-gemac", "hisilicon,hisi-gemac-v1";
+			compatible = "hisilicon,hix5hd2-gmac", "hisilicon,hisi-gmac-v1";
 			reg = <0x1840000 0x1000>,<0x184300c 0x4>;
 			interrupts = <0 71 4>;
 			clocks = <&clock HIX5HD2_MAC0_CLK>;
@@ -445,7 +445,7 @@
 		};
 
 		gmac1: ethernet@1841000 {
-			compatible = "hisilicon,hix5hd2-gemac", "hisilicon,hisi-gemac-v1";
+			compatible = "hisilicon,hix5hd2-gmac", "hisilicon,hisi-gmac-v1";
 			reg = <0x1841000 0x1000>,<0x1843010 0x4>;
 			interrupts = <0 72 4>;
 			clocks = <&clock HIX5HD2_MAC1_CLK>;
-- 
2.8.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
