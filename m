From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v5 07/10] arm64: dts: allwinner: add snps,dwmac-mdio compatible to emac/mdio
Date: Fri,  8 Sep 2017 09:11:53 +0200
Message-ID: <20170908071156.5115-8-clabbe.montjoie@gmail.com>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

stmmac bindings docs said that its mdio node must have
compatible = "snps,dwmac-mdio";
Since dwmac-sun8i does not have any good reasons to not doing it, all
their MDIO node must have it.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi b/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
index 4dd9ffef0d80..5dceebd81f09 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
+++ b/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
@@ -476,6 +476,7 @@
 			#size-cells = <0>;
 
 			mdio: mdio {
+				compatible = "snps,dwmac-mdio";
 				#address-cells = <1>;
 				#size-cells = <0>;
 			};
-- 
2.13.5
