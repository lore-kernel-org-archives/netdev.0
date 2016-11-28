From: Jerome Brunet <jbrunet@baylibre.com>
Subject: [PATCH net-next v3 4/4] ARM64: dts: meson: odroidc2: disable advertisement EEE for GbE.
Date: Mon, 28 Nov 2016 10:46:49 +0100
Message-ID: <1480326409-25419-5-git-send-email-jbrunet@baylibre.com>
References: <1480326409-25419-1-git-send-email-jbrunet@baylibre.com>
Cc: Jerome Brunet <jbrunet@baylibre.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Andre Roth <neolynx@gmail.com>, Andrew Lunn <andrew@lunn.ch>,
        Neil Armstrong <narmstrong@baylibre.com>,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480326409-25419-1-git-send-email-jbrunet@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jerome Brunet <jbrunet@baylibre.com>
---
 arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts b/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts
index e6e3491d48a5..5624714d2b16 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts
+++ b/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts
@@ -46,6 +46,7 @@
 
 #include "meson-gxbb.dtsi"
 #include <dt-bindings/gpio/gpio.h>
+#include <dt-bindings/net/mdio.h>
 
 / {
 	compatible = "hardkernel,odroid-c2", "amlogic,meson-gxbb";
@@ -98,3 +99,18 @@
 	pinctrl-0 = <&i2c_a_pins>;
 	pinctrl-names = "default";
 };
+
+&ethmac {
+	phy-handle = <&eth_phy0>;
+
+	mdio {
+		compatible = "snps,dwmac-mdio";
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		eth_phy0: ethernet-phy@0 {
+			reg = <0>;
+			eee-broken-modes = <MDIO_EEE_1000T>;
+		};
+	};
+};
-- 
2.7.4
