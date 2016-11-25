From: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: [PATCH v2 7/7] ARM64: dts: amlogic: add the ethernet TX delay configuration
Date: Fri, 25 Nov 2016 14:01:56 +0100
Message-ID: <20161125130156.17879-8-martin.blumenstingl@googlemail.com>
References: <20161124143417.10178-1-martin.blumenstingl@googlemail.com>
 <20161125130156.17879-1-martin.blumenstingl@googlemail.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
        peppe.cavallaro-qxv4g6HH51o@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
        catalin.marinas-5wv7dgnIgG8@public.gmane.org, carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
To: linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161125130156.17879-1-martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This adds the amlogic,tx-delay-ns with the old (hardcoded) default value
of 2ns to all boards which are using an RGMII ethernet PHY.

Signed-off-by: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
---
 arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts  | 2 ++
 arch/arm64/boot/dts/amlogic/meson-gxbb-p20x.dtsi     | 2 ++
 arch/arm64/boot/dts/amlogic/meson-gxbb-vega-s95.dtsi | 2 ++
 arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p230.dts | 2 ++
 arch/arm64/boot/dts/amlogic/meson-gxm-nexbox-a1.dts  | 2 ++
 arch/arm64/boot/dts/amlogic/meson-gxm-s912-q200.dts  | 2 ++
 6 files changed, 12 insertions(+)

diff --git a/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts b/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts
index cbaf024..fdade07 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts
+++ b/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts
@@ -161,6 +161,8 @@
 	snps,reset-delays-us = <0 10000 1000000>;
 	snps,reset-active-low;
 
+	amlogic,tx-delay-ns = <2>;
+
 	phy-mode = "rgmii";
 };
 
diff --git a/arch/arm64/boot/dts/amlogic/meson-gxbb-p20x.dtsi b/arch/arm64/boot/dts/amlogic/meson-gxbb-p20x.dtsi
index 2abc553..8172e12 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxbb-p20x.dtsi
+++ b/arch/arm64/boot/dts/amlogic/meson-gxbb-p20x.dtsi
@@ -152,6 +152,8 @@
 	snps,reset-delays-us = <0 10000 1000000>;
 	snps,reset-active-low;
 
+	amlogic,tx-delay-ns = <2>;
+
 	phy-mode = "rgmii";
 };
 
diff --git a/arch/arm64/boot/dts/amlogic/meson-gxbb-vega-s95.dtsi b/arch/arm64/boot/dts/amlogic/meson-gxbb-vega-s95.dtsi
index a0e92e3..ab49712 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxbb-vega-s95.dtsi
+++ b/arch/arm64/boot/dts/amlogic/meson-gxbb-vega-s95.dtsi
@@ -131,6 +131,8 @@
 	snps,reset-delays-us = <0 10000 1000000>;
 	snps,reset-active-low;
 
+	amlogic,tx-delay-ns = <2>;
+
 	phy-mode = "rgmii";
 };
 
diff --git a/arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p230.dts b/arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p230.dts
index f66939c..7fd11c6 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p230.dts
+++ b/arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p230.dts
@@ -64,6 +64,8 @@
 	snps,reset-delays-us = <0 10000 1000000>;
 	snps,reset-active-low;
 
+	amlogic,tx-delay-ns = <2>;
+
 	/* External PHY is in RGMII */
 	phy-mode = "rgmii";
 };
diff --git a/arch/arm64/boot/dts/amlogic/meson-gxm-nexbox-a1.dts b/arch/arm64/boot/dts/amlogic/meson-gxm-nexbox-a1.dts
index d320727..f83d6dc 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxm-nexbox-a1.dts
+++ b/arch/arm64/boot/dts/amlogic/meson-gxm-nexbox-a1.dts
@@ -156,6 +156,8 @@
 	snps,reset-delays-us = <0 10000 1000000>;
 	snps,reset-active-low;
 
+	amlogic,tx-delay-ns = <2>;
+
 	/* External PHY is in RGMII */
 	phy-mode = "rgmii";
 };
diff --git a/arch/arm64/boot/dts/amlogic/meson-gxm-s912-q200.dts b/arch/arm64/boot/dts/amlogic/meson-gxm-s912-q200.dts
index 5dbc660..e428e29 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxm-s912-q200.dts
+++ b/arch/arm64/boot/dts/amlogic/meson-gxm-s912-q200.dts
@@ -64,6 +64,8 @@
 	snps,reset-delays-us = <0 10000 1000000>;
 	snps,reset-active-low;
 
+	amlogic,tx-delay-ns = <2>;
+
 	/* External PHY is in RGMII */
 	phy-mode = "rgmii";
 };
-- 
2.10.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
