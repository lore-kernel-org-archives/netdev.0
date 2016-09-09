From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 6/9] ARM: dts: sun8i: Enable sun8i-emac on the Orange PI PC
Date: Fri,  9 Sep 2016 14:45:14 +0200
Message-ID: <1473425117-18645-7-git-send-email-clabbe.montjoie@gmail.com>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sun8i-emac hardware is present on the Orange PI PC.
It uses the internal PHY.

This patch create the needed emac and phy nodes.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts b/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
index daf50b9a6..24f8e97 100644
--- a/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
+++ b/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
@@ -165,3 +165,13 @@
 	/* USB VBUS is always on */
 	status = "okay";
 };
+
+&emac {
+	phy = <&phy1>;
+	phy-mode = "mii";
+	allwinner,leds-active-low;
+	status = "okay";
+	phy1: ethernet-phy@1 {
+		reg = <1>;
+	};
+};
-- 
2.7.3
