From: Chen-Yu Tsai <wens@csie.org>
Subject: [PATCH RFC 5/5] ARM: dts: sun8i: Enable Ethernet controller on the Orange PI PC
Date: Tue,  5 Apr 2016 00:22:34 +0800
Message-ID: <1459786954-12649-6-git-send-email-wens@csie.org>
References: <1459786954-12649-1-git-send-email-wens@csie.org>
Cc: Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	LABBE Corentin <clabbe.montjoie@gmail.com>
To: Maxime Ripard <maxime.ripard@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459786954-12649-1-git-send-email-wens@csie.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Orange PI PC uses the H3's internal Ethernet PHY with the EMAC
Ethernet controller.

Set a proper address for the PHY and enable the EMAC.

Signed-off-by: Chen-Yu Tsai <wens@csie.org>
---

This patch depends on "ARM: dts: sun8i-h3: Add Ethernet controller device",
which uses an binding still in development.

Do not merge.

---
 arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts b/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
index daf50b9a6657..f01e10df812a 100644
--- a/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
+++ b/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
@@ -102,6 +102,20 @@
 	status = "okay";
 };
 
+&ephy {
+	allwinner,ephy-addr = <0x1>;
+};
+
+&emac {
+	phy = <&phy1>;
+	phy-mode = "mii";
+	status = "okay";
+
+	phy1: ethernet-phy@1 {
+		reg = <1>;
+	};
+};
+
 &ir {
 	pinctrl-names = "default";
 	pinctrl-0 = <&ir_pins_a>;
-- 
2.7.0
