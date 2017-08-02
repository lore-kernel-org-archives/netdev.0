From: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [PATCH v3 08/11] ARM: dts: rk322x: Add support internal phy for gmac
Date: Wed,  2 Aug 2017 14:23:40 +0800
Message-ID: <1501655020-19777-1-git-send-email-david.wu@rock-chips.com>
References: <1501654546-17292-1-git-send-email-david.wu@rock-chips.com>
Cc: peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
        huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org, hwg-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org, olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1501654546-17292-1-git-send-email-david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds internal mac phy clock and internal mac phy reset
for rk gmac using.

Signed-off-by: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
---
 arch/arm/boot/dts/rk322x.dtsi | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/arm/boot/dts/rk322x.dtsi b/arch/arm/boot/dts/rk322x.dtsi
index f3e4ffd..3778f7d 100644
--- a/arch/arm/boot/dts/rk322x.dtsi
+++ b/arch/arm/boot/dts/rk322x.dtsi
@@ -611,13 +611,13 @@
 		clocks = <&cru SCLK_MAC>, <&cru SCLK_MAC_RX>,
 			<&cru SCLK_MAC_TX>, <&cru SCLK_MAC_REF>,
 			<&cru SCLK_MAC_REFOUT>, <&cru ACLK_GMAC>,
-			<&cru PCLK_GMAC>;
+			<&cru PCLK_GMAC>, <&cru SCLK_MAC_PHY>;
 		clock-names = "stmmaceth", "mac_clk_rx",
 			"mac_clk_tx", "clk_mac_ref",
 			"clk_mac_refout", "aclk_mac",
-			"pclk_mac";
-		resets = <&cru SRST_GMAC>;
-		reset-names = "stmmaceth";
+			"pclk_mac", "clk_macphy";
+		resets = <&cru SRST_GMAC>, <&cru SRST_MACPHY>;
+		reset-names = "stmmaceth", "mac-phy";
 		rockchip,grf = <&grf>;
 		status = "disabled";
 	};
-- 
1.9.1


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
