From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH net-next 1/1] ARM: dts: imx6sx: correct i.MX6sx sdb board enet
 phy address
Date: Mon, 19 Jan 2015 17:38:02 +0800
Message-ID: <1421660282-29494-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de, b38611@freescale.com,
 stefan@agner.ch, linux-arm-kernel@lists.infradead.org
To: <shawn.guo@linaro.org>, <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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

The commit (3d125f9c91c5) cause i.MX6SX sdb enet cannot work. The cause is
the commit add mdio node with un-correct phy address.

The patch just correct i.MX6sx sdb board enet phy address.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 arch/arm/boot/dts/imx6sx-sdb.dts |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/imx6sx-sdb.dts b/arch/arm/boot/dts/imx6sx-sdb.dts
index 8c1febd..9db123f 100644
--- a/arch/arm/boot/dts/imx6sx-sdb.dts
+++ b/arch/arm/boot/dts/imx6sx-sdb.dts
@@ -167,11 +167,11 @@
 		#size-cells = <0>;
 
 		ethphy1: ethernet-phy@0 {
-			reg = <0>;
+			reg = <1>;
 		};
 
 		ethphy2: ethernet-phy@1 {
-			reg = <1>;
+			reg = <2>;
 		};
 	};
 };
-- 
1.7.8
