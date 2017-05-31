From: Leonard Crestez <leonard.crestez@nxp.com>
Subject: [PATCH v2 1/2] ARM: dts: imx6ul-14x14-evk: Add ksz8081 phy properties
Date: Wed, 31 May 2017 13:29:29 +0300
Message-ID: <1adf8f0d44afec4d11dec7f09d54d37d58cda5ff.1496224930.git.leonard.crestez@nxp.com>
References: <cover.1496224930.git.leonard.crestez@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andy Duan <fugang.duan@nxp.com>, Johan Hovold <johan@kernel.org>,
        Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Philipp Zabel <p.zabel@pengutronix.de>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
        <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Shawn Guo <shawnguo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1496224930.git.leonard.crestez@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Right now mach-imx6ul registers a fixup for the ksz8081 phy. The same
register values can be set through the micrel phy driver by using dts
properties.

This seems preferable and allows cleanly fixing suspend/resume.

Signed-off-by: Leonard Crestez <leonard.crestez@nxp.com>
Reviewed-by: Fabio Estevam <fabio.estevam@nxp.com>
---
 arch/arm/boot/dts/imx6ul-14x14-evk.dts | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/arm/boot/dts/imx6ul-14x14-evk.dts b/arch/arm/boot/dts/imx6ul-14x14-evk.dts
index f18e1f1..d2be8aa 100644
--- a/arch/arm/boot/dts/imx6ul-14x14-evk.dts
+++ b/arch/arm/boot/dts/imx6ul-14x14-evk.dts
@@ -120,10 +120,16 @@
 
 		ethphy0: ethernet-phy@2 {
 			reg = <2>;
+			micrel,led-mode = <1>;
+			clocks = <&clks IMX6UL_CLK_ENET_REF>;
+			clock-names = "rmii-ref";
 		};
 
 		ethphy1: ethernet-phy@1 {
 			reg = <1>;
+			micrel,led-mode = <1>;
+			clocks = <&clks IMX6UL_CLK_ENET2_REF>;
+			clock-names = "rmii-ref";
 		};
 	};
 };
-- 
2.7.4
