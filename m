From: Leonard Crestez <leonard.crestez@nxp.com>
Subject: [PATCH 1/2] ARM: dts: imx6ul-14x14-evk: Add ksz8081 phy properties
Date: Tue, 30 May 2017 20:34:03 +0300
Message-ID: <d31aab90fbdecaf4c5f240becb2d0b0efb23f5c3.1496164448.git.leonard.crestez@nxp.com>
References: <cover.1496164448.git.leonard.crestez@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Johan Hovold <johan@kernel.org>,
 linux-kernel@vger.kernel.org,
 Alexandre Belloni <alexandre.belloni@free-electrons.com>,
 Philipp Zabel <p.zabel@pengutronix.de>, Fabio Estevam <fabio.estevam@nxp.com>,
 linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawnguo@kernel.org>, Florian Fainelli <f.fainelli@gmail.com>,
 Andrew Lunn <andrew@lunn.ch>, Andy Duan <fugang.duan@nxp.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <cover.1496164448.git.leonard.crestez@nxp.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Right now mach-imx6ul registers a fixup for the ksz8081 phy. The same
register values can be set through the micrel phy driver by using dts
properties.

This seems preferable and allows cleanly fixing suspend/resume.

Signed-off-by: Leonard Crestez <leonard.crestez@nxp.com>
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
