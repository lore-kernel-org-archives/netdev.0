From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH v2 2/4] ARM: dts: Add regulator voltage settings for vcc_phy in rk3288-evb.dtsi
Date: Tue, 20 Jan 2015 07:09:38 +0000
Message-ID: <1421737780-1533-3-git-send-email-romain.perier@gmail.com>
References: <1421737780-1533-1-git-send-email-romain.perier@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	heiko@sntech.de, linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	roger.chen@rock-chips.com
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421737780-1533-1-git-send-email-romain.perier@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Romain Perier <romain.perier@gmail.com>
---
 arch/arm/boot/dts/rk3288-evb.dtsi | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm/boot/dts/rk3288-evb.dtsi b/arch/arm/boot/dts/rk3288-evb.dtsi
index 489643c..1c08eb0 100644
--- a/arch/arm/boot/dts/rk3288-evb.dtsi
+++ b/arch/arm/boot/dts/rk3288-evb.dtsi
@@ -98,6 +98,8 @@
 		pinctrl-names = "default";
 		pinctrl-0 = <&eth_phy_pwr>;
 		regulator-name = "vcc_phy";
+		regulator-min-microvolt = <3300000>;
+		regulator-max-microvolt = <3300000>;
 		regulator-always-on;
 		regulator-boot-on;
 	};
-- 
1.9.1
