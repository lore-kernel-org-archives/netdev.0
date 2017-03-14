From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 06/20] ARM: dts: sunxi-h3-h5: Add dt node for the syscon control module
Date: Tue, 14 Mar 2017 15:18:42 +0100
Message-ID: <20170314141856.24560-7-clabbe.montjoie@gmail.com>
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

This patch add the dt node for the syscon register present on the
Allwinner H3/H5

Only two register are present in this syscon and the only one useful is
the one dedicated to EMAC clock..

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm/boot/dts/sunxi-h3-h5.dtsi | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/arm/boot/dts/sunxi-h3-h5.dtsi b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
index 2494ea0..07e4f36 100644
--- a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
+++ b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
@@ -102,6 +102,12 @@
 		#size-cells = <1>;
 		ranges;
 
+		syscon: syscon@01c00000 {
+			compatible = "syscon",
+				"allwinner,sun8i-h3-system-controller";
+			reg = <0x01c00000 0x1000>;
+		};
+
 		dma: dma-controller@01c02000 {
 			compatible = "allwinner,sun8i-h3-dma";
 			reg = <0x01c02000 0x1000>;
-- 
2.10.2
