From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH v1 4/4] ARM: dts: Convert gmac to phy-supply in rk3288-evb-rk808.dts
Date: Mon, 19 Jan 2015 18:08:09 +0000
Message-ID: <1421690889-11901-5-git-send-email-romain.perier@gmail.com>
References: <1421690889-11901-1-git-send-email-romain.perier@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	heiko@sntech.de, linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	roger.chen@rock-chips.com
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421690889-11901-1-git-send-email-romain.perier@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This replaces the property phy_regulator by the standard devicetree property
phy-supply and references the device_node vcc_phy from it.

Signed-off-by: Romain Perier <romain.perier@gmail.com>
---
 arch/arm/boot/dts/rk3288-evb-rk808.dts | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm/boot/dts/rk3288-evb-rk808.dts b/arch/arm/boot/dts/rk3288-evb-rk808.dts
index 831a7aa..e1d3eeb 100644
--- a/arch/arm/boot/dts/rk3288-evb-rk808.dts
+++ b/arch/arm/boot/dts/rk3288-evb-rk808.dts
@@ -161,7 +161,7 @@
 };
 
 &gmac {
-	phy_regulator = "vcc_phy";
+	phy-supply = <&vcc_phy>;
 	phy-mode = "rgmii";
 	clock_in_out = "input";
 	snps,reset-gpio = <&gpio4 7 0>;
-- 
1.9.1
