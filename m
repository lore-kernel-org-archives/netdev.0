From: Jerome Brunet <jbrunet@baylibre.com>
Subject: [PATCH net 3/3] ARM64: dts: meson: odroidc2: disable 1000t-eee advertisement
Date: Tue, 15 Nov 2016 15:29:14 +0100
Message-ID: <1479220154-25851-4-git-send-email-jbrunet@baylibre.com>
References: <1479220154-25851-1-git-send-email-jbrunet@baylibre.com>
Cc: Jerome Brunet <jbrunet@baylibre.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Andre Roth <neolynx@gmail.com>,
        Neil Armstrong <narmstrong@baylibre.com>,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479220154-25851-1-git-send-email-jbrunet@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reported-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre TORGUE <alexandre.torgue@st.com>
Signed-off-by: Jerome Brunet <jbrunet@baylibre.com>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
Tested-by: Andre Roth <neolynx@gmail.com>
---
 arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts b/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts
index e6e3491d48a5..1f4416ecb183 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts
+++ b/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts
@@ -98,3 +98,18 @@
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
+			realtek,disable-eee-1000t;
+		};
+	};
+};
-- 
2.7.4
