From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 13/20] ARM: dts: sun8i: orangepi-pc-plus: Set EMAC activity LEDs to active high
Date: Tue, 14 Mar 2017 15:18:49 +0100
Message-ID: <20170314141856.24560-14-clabbe.montjoie@gmail.com>
References: <20170314141856.24560-1-clabbe.montjoie@gmail.com>
Cc: f.fainelli@gmail.com, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314141856.24560-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On the Orange Pi PC Plus, the polarity of the LEDs on the RJ45 Ethernet
port were changed from active low to active high.

Signed-off-by: Chen-Yu Tsai <wens@csie.org>
Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts b/arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts
index 8b93f5c..0380769 100644
--- a/arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts
+++ b/arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts
@@ -86,3 +86,8 @@
 	/* eMMC is missing pull-ups */
 	bias-pull-up;
 };
+
+&emac {
+	/* LEDs changed to active high on the plus */
+	/delete-property/ allwinner,leds-active-low;
+};
-- 
2.10.2
