From: George Cherian <george.cherian-l0cyMroinI0@public.gmane.org>
Subject: [PATCH 6/6] ARM: dts: am4372: Add clock names for cpsw and cpts
Date: Mon, 28 Apr 2014 09:40:25 +0530
Message-ID: <1398658225-25873-7-git-send-email-george.cherian@ti.com>
References: <1398658225-25873-1-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	<ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>, <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>, <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	<bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, <zonque-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <balbi-l0cyMroinI0@public.gmane.org>,
	<mugunthanvnm-l0cyMroinI0@public.gmane.org>, <george.cherian-l0cyMroinI0@public.gmane.org>, <t-kristo-l0cyMroinI0@public.gmane.org>,
	<mturquette-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	<galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	<mark.rutland-5wv7dgnIgG8@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>, <bcousson-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1398658225-25873-1-git-send-email-george.cherian-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add CPSW fck and CPTS clock and clock names for AM4372

Signed-off-by: George Cherian <george.cherian-l0cyMroinI0@public.gmane.org>
---
 arch/arm/boot/dts/am4372.dtsi | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm/boot/dts/am4372.dtsi b/arch/arm/boot/dts/am4372.dtsi
index 36d523a..c2779f6 100644
--- a/arch/arm/boot/dts/am4372.dtsi
+++ b/arch/arm/boot/dts/am4372.dtsi
@@ -489,6 +489,8 @@
 			#address-cells = <1>;
 			#size-cells = <1>;
 			ti,hwmods = "cpgmac0";
+			clocks = <&cpsw_125mhz_gclk>, <&cpsw_cpts_rft_clk>;
+			clock-names = "fck", "cpts";
 			status = "disabled";
 			cpdma_channels = <8>;
 			ale_entries = <1024>;
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
