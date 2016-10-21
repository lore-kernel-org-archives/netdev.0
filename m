From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH 05/13] ARM64: dts: meson-gxl: Add i2c nodes
Date: Fri, 21 Oct 2016 16:40:30 +0200
Message-ID: <1477060838-14164-6-git-send-email-narmstrong@baylibre.com>
References: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>,
        linux-gpio@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-amlogic@lists.infradead.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: khilman@baylibre.com, carlo@caione.org, linus.walleij@linaro.org
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add i2c nodes clock attributes for Amlogic Meson GXL.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 arch/arm64/boot/dts/amlogic/meson-gxl.dtsi | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi b/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
index 33d0506..b45df2a 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
+++ b/arch/arm64/boot/dts/amlogic/meson-gxl.dtsi
@@ -223,3 +223,15 @@
 		reg = <0x0 0x0 0x0 0x3db>;
 	};
 };
+
+&i2c_A {
+	clocks = <&clkc CLKID_I2C>;
+};
+
+&i2c_B {
+	clocks = <&clkc CLKID_I2C>;
+};
+
+&i2c_C {
+	clocks = <&clkc CLKID_I2C>;
+};
-- 
1.9.1

