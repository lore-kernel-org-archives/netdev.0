From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH 5/5] ARM: dts: sun8i: Enable sun8i-emac on the Orange PI PC
Date: Fri,  3 Jun 2016 11:56:30 +0200
Message-ID: <1464947790-22991-6-git-send-email-clabbe.montjoie@gmail.com>
References: <1464947790-22991-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-sunxi@googlegroups.com,
	LABBE Corentin <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	maxime.ripard@free-electrons.com, wens@csie.org,
	linux@armlinux.org.uk, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464947790-22991-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sun8i-emac hardware is present on the Orange PI PC.
It uses the internal PHY.

This patch create the needed emac and phy nodes.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts b/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
index daf50b9a6..b8340f7 100644
--- a/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
+++ b/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
@@ -165,3 +165,14 @@
 	/* USB VBUS is always on */
 	status = "okay";
 };
+
+&emac {
+	phy = <&phy1>;
+	phy-mode = "mii";
+	allwinner,use-internal-phy;
+	allwinner,leds-active-low;
+	status = "okay";
+	phy1: ethernet-phy@1 {
+		reg = <1>;
+	};
+};
-- 
2.7.3
