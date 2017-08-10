From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 2/3] ARM: sun8i: sunxi-h3-h5: add phy-is-integrated property to internal PHY
Date: Thu, 10 Aug 2017 10:51:28 +0200
Message-ID: <20170810085129.20463-3-clabbe.montjoie@gmail.com>
References: <20170810085129.20463-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com, linux@armlinux.org.uk,
        maxime.ripard@free-electrons.com, wens@csie.org,
        peppe.cavallaro@st.com, alexandre.torgue@st.com, andrew@lunn.ch,
        f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170810085129.20463-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch add the new phy-is-integrated property to the internal PHY
node.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm/boot/dts/sunxi-h3-h5.dtsi | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm/boot/dts/sunxi-h3-h5.dtsi b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
index 4b599b5d26f6..54fc24e4c569 100644
--- a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
+++ b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
@@ -425,6 +425,7 @@
 					reg = <1>;
 					clocks = <&ccu CLK_BUS_EPHY>;
 					resets = <&ccu RST_BUS_EPHY>;
+					phy-is-integrated;
 				};
 			};
 		};
-- 
2.13.0
