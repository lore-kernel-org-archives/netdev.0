From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: [PATCH 5/6] ARM: keystone: dts: fix netcp clocks and add names
Date: Mon, 28 Nov 2016 17:04:27 -0600
Message-ID: <20161128230428.6872-6-grygorii.strashko@ti.com>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161128230428.6872-1-grygorii.strashko-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>

Fix the pa clock to point to the clkpa which has clock rate of 1/3 of PA
PLL clock and add clock names.

Signed-off-by: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
---
 arch/arm/boot/dts/keystone-k2e-netcp.dtsi  | 3 ++-
 arch/arm/boot/dts/keystone-k2hk-netcp.dtsi | 3 ++-
 arch/arm/boot/dts/keystone-k2l-netcp.dtsi  | 3 ++-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/arch/arm/boot/dts/keystone-k2e-netcp.dtsi b/arch/arm/boot/dts/keystone-k2e-netcp.dtsi
index ac990f6..ba828cb 100644
--- a/arch/arm/boot/dts/keystone-k2e-netcp.dtsi
+++ b/arch/arm/boot/dts/keystone-k2e-netcp.dtsi
@@ -138,7 +138,8 @@ netcp: netcp@24000000 {
 	/* NetCP address range */
 	ranges = <0 0x24000000 0x1000000>;
 
-	clocks = <&papllclk>, <&clkcpgmac>, <&chipclk12>;
+	clocks = <&clkpa>, <&clkcpgmac>, <&chipclk12>;
+	clock-names = "pa_clk", "ethss_clk", "cpts";
 	dma-coherent;
 
 	ti,navigator-dmas = <&dma_gbe 0>,
diff --git a/arch/arm/boot/dts/keystone-k2hk-netcp.dtsi b/arch/arm/boot/dts/keystone-k2hk-netcp.dtsi
index f86d6dd..a5ac845 100644
--- a/arch/arm/boot/dts/keystone-k2hk-netcp.dtsi
+++ b/arch/arm/boot/dts/keystone-k2hk-netcp.dtsi
@@ -155,7 +155,8 @@ netcp: netcp@2000000 {
 	/* NetCP address range */
 	ranges  = <0 0x2000000 0x100000>;
 
-	clocks = <&papllclk>, <&clkcpgmac>, <&chipclk12>;
+	clocks = <&clkpa>, <&clkcpgmac>, <&chipclk12>;
+	clock-names = "pa_clk", "ethss_clk", "cpts";
 	dma-coherent;
 
 	ti,navigator-dmas = <&dma_gbe 22>,
diff --git a/arch/arm/boot/dts/keystone-k2l-netcp.dtsi b/arch/arm/boot/dts/keystone-k2l-netcp.dtsi
index 5acbd0d..b6f2682 100644
--- a/arch/arm/boot/dts/keystone-k2l-netcp.dtsi
+++ b/arch/arm/boot/dts/keystone-k2l-netcp.dtsi
@@ -137,7 +137,8 @@ netcp: netcp@26000000 {
 	/* NetCP address range */
 	ranges = <0 0x26000000 0x1000000>;
 
-	clocks = <&clkosr>, <&papllclk>, <&clkcpgmac>, <&chipclk12>;
+	clocks = <&clkpa>, <&clkcpgmac>, <&chipclk12>, <&clkosr>;
+	clock-names = "pa_clk", "ethss_clk", "cpts", "osr_clk";
 	dma-coherent;
 
 	ti,navigator-dmas = <&dma_gbe 0>,
-- 
2.10.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
