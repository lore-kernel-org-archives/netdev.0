From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 14/20] ARM64: dts: sun50i-a64: Add dt node for the syscon control module
Date: Mon,  3 Apr 2017 11:14:38 +0200
Message-ID: <20170403091444.29876-15-clabbe.montjoie@gmail.com>
References: <20170403091444.29876-1-clabbe.montjoie@gmail.com>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170403091444.29876-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch add the dt node for the syscon register present on the
Allwinner A64.

Only two register are present in this syscon and the only one useful is
the one dedicated to EMAC clock.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi b/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
index 1c64ea2..1683a1f 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
+++ b/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
@@ -121,6 +121,12 @@
 		#size-cells = <1>;
 		ranges;
 
+		syscon: syscon@01c00000 {
+			compatible = "allwinner,sun8i-a64-system-controller",
+				"syscon";
+			reg = <0x01c00000 0x1000>;
+		};
+
 		mmc0: mmc@1c0f000 {
 			compatible = "allwinner,sun50i-a64-mmc";
 			reg = <0x01c0f000 0x1000>;
-- 
2.10.2
