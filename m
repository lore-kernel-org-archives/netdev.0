From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH v2 5/5] ARM64: dts: meson-gxl-s905x: Enable internal ethernet PHY
Date: Mon, 31 Oct 2016 17:56:27 +0100
Message-ID: <1477932987-27871-6-git-send-email-narmstrong@baylibre.com>
References: <1477932987-27871-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>, netdev@vger.kernel.org,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org
To: f.fainelli@gmail.com, khilman@baylibre.com, carlo@caione.org,
        andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477932987-27871-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 arch/arm64/boot/dts/amlogic/meson-gxl-s905x.dtsi | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/arm64/boot/dts/amlogic/meson-gxl-s905x.dtsi b/arch/arm64/boot/dts/amlogic/meson-gxl-s905x.dtsi
index 07f0e0b..08237ee 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxl-s905x.dtsi
+++ b/arch/arm64/boot/dts/amlogic/meson-gxl-s905x.dtsi
@@ -46,3 +46,9 @@
 / {
 	compatible = "amlogic,s905x", "amlogic,meson-gxl";
 };
+
+/* S905X Only has access to its internal PHY */
+&ethmac {
+	phy-mode = "rmii";
+	phy-handle = <&internal_phy>;
+};
-- 
1.9.1
