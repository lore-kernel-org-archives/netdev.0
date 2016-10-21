From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH 04/13] ARM64: dts: meson-gxl: Add clock nodes
Date: Fri, 21 Oct 2016 16:40:29 +0200
Message-ID: <1477060838-14164-5-git-send-email-narmstrong@baylibre.com>
References: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>,
        linux-gpio@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-amlogic@lists.infradead.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: khilman@baylibre.com, carlo@caione.org, linus.walleij@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add clock node for Amlogic Meson GXL.
The GXBB compatible is retained since the GXBB clock tree is used for now.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 arch/arm64/boot/dts/amlogic/meson-gxl.dtsi | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi b/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
index ce7f550..33d0506 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
+++ b/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
@@ -42,6 +42,7 @@
  */
 
 #include "meson-gx.dtsi"
+#include <dt-bindings/clock/gxbb-clkc.h>
 #include <dt-bindings/gpio/meson-gxl-gpio.h>
 
 / {
@@ -214,3 +215,11 @@
 		};
 	};
 };
+
+&hiubus {
+	clkc: clock-controller@0 {
+		compatible = "amlogic,gxl-clkc", "amlogic,gxbb-clkc";
+		#clock-cells = <1>;
+		reg = <0x0 0x0 0x0 0x3db>;
+	};
+};
-- 
1.9.1
