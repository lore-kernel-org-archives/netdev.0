From: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [PATCH v4 5/6] arm64: dts: rockchip: add the gmac needed node for
 rk3399
Date: Fri,  2 Sep 2016 01:50:03 +0800
Message-ID: <1472752204-8924-6-git-send-email-wxt@rock-chips.com>
References: <1472752204-8924-1-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, Huang Tao <huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Brian Norris <briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Elaine Zhang <zhangqing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 dbasehore-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
 Douglas Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>, David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Shunqian Zheng <zhengsq-TNX95d0MmH7DzftRWevZcw@public.gmane.org>, Jianqun Xu <jay.xu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
To: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1472752204-8924-1-git-send-email-wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>

The RK3399 GMAC Ethernet Controller provides a complete Ethernet interface
from processor to a Reduced Media Independent Interface (RMII) and Reduced
Gigabit Media Independent Interface (RGMII) compliant Ethernet PHY.

This patch adds the related needed device information.
e.g.: interrupts, grf, clocks, pinctrl and so on.

The full details are in [0].

[0]:
Documentation/devicetree/bindings/net/rockchip-dwmac.txt

Signed-off-by: Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Signed-off-by: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
---

Changes in v4:
- The Roger had posted patch on https://patchwork.kernel.org/patch/9274561/.
- re-fixup to original author.

Changes in v3:
- generate a patch from https://patchwork.kernel.org/patch/9306339/.

Changes in v2: None

 arch/arm64/boot/dts/rockchip/rk3399.dtsi | 80 ++++++++++++++++++++++++++++++++
 1 file changed, 80 insertions(+)

diff --git a/arch/arm64/boot/dts/rockchip/rk3399.dtsi b/arch/arm64/boot/dts/rockchip/rk3399.dtsi
index 2ab233f..092bb45 100644
--- a/arch/arm64/boot/dts/rockchip/rk3399.dtsi
+++ b/arch/arm64/boot/dts/rockchip/rk3399.dtsi
@@ -200,6 +200,26 @@
 		};
 	};
 
+	gmac: ethernet@fe300000 {
+		compatible = "rockchip,rk3399-gmac";
+		reg = <0x0 0xfe300000 0x0 0x10000>;
+		interrupts = <GIC_SPI 12 IRQ_TYPE_LEVEL_HIGH>;
+		interrupt-names = "macirq";
+		clocks = <&cru SCLK_MAC>, <&cru SCLK_MAC_RX>,
+			 <&cru SCLK_MAC_TX>, <&cru SCLK_MACREF>,
+			 <&cru SCLK_MACREF_OUT>, <&cru ACLK_GMAC>,
+			 <&cru PCLK_GMAC>;
+		clock-names = "stmmaceth", "mac_clk_rx",
+			      "mac_clk_tx", "clk_mac_ref",
+			      "clk_mac_refout", "aclk_mac",
+			      "pclk_mac";
+		power-domains = <&power RK3399_PD_GMAC>;
+		resets = <&cru SRST_A_GMAC>;
+		reset-names = "stmmaceth";
+		rockchip,grf = <&grf>;
+		status = "disabled";
+	};
+
 	sdio0: dwmmc@fe310000 {
 		compatible = "rockchip,rk3399-dw-mshc",
 			     "rockchip,rk3288-dw-mshc";
@@ -1193,6 +1213,66 @@
 			drive-strength = <13>;
 		};
 
+		gmac {
+			rgmii_pins: rgmii-pins {
+				rockchip,pins =
+					/* mac_txclk */
+					<3 17 RK_FUNC_1 &pcfg_pull_none_13ma>,
+					/* mac_rxclk */
+					<3 14 RK_FUNC_1 &pcfg_pull_none>,
+					/* mac_mdio */
+					<3 13 RK_FUNC_1 &pcfg_pull_none>,
+					/* mac_txen */
+					<3 12 RK_FUNC_1 &pcfg_pull_none_13ma>,
+					/* mac_clk */
+					<3 11 RK_FUNC_1 &pcfg_pull_none>,
+					/* mac_rxdv */
+					<3 9 RK_FUNC_1 &pcfg_pull_none>,
+					/* mac_mdc */
+					<3 8 RK_FUNC_1 &pcfg_pull_none>,
+					/* mac_rxd1 */
+					<3 7 RK_FUNC_1 &pcfg_pull_none>,
+					/* mac_rxd0 */
+					<3 6 RK_FUNC_1 &pcfg_pull_none>,
+					/* mac_txd1 */
+					<3 5 RK_FUNC_1 &pcfg_pull_none_13ma>,
+					/* mac_txd0 */
+					<3 4 RK_FUNC_1 &pcfg_pull_none_13ma>,
+					/* mac_rxd3 */
+					<3 3 RK_FUNC_1 &pcfg_pull_none>,
+					/* mac_rxd2 */
+					<3 2 RK_FUNC_1 &pcfg_pull_none>,
+					/* mac_txd3 */
+					<3 1 RK_FUNC_1 &pcfg_pull_none_13ma>,
+					/* mac_txd2 */
+					<3 0 RK_FUNC_1 &pcfg_pull_none_13ma>;
+			};
+
+			rmii_pins: rmii-pins {
+				rockchip,pins =
+					/* mac_mdio */
+					<3 13 RK_FUNC_1 &pcfg_pull_none>,
+					/* mac_txen */
+					<3 12 RK_FUNC_1 &pcfg_pull_none_13ma>,
+					/* mac_clk */
+					<3 11 RK_FUNC_1 &pcfg_pull_none>,
+					/* mac_rxer */
+					<3 10 RK_FUNC_1 &pcfg_pull_none>,
+					/* mac_rxdv */
+					<3 9 RK_FUNC_1 &pcfg_pull_none>,
+					/* mac_mdc */
+					<3 8 RK_FUNC_1 &pcfg_pull_none>,
+					/* mac_rxd1 */
+					<3 7 RK_FUNC_1 &pcfg_pull_none>,
+					/* mac_rxd0 */
+					<3 6 RK_FUNC_1 &pcfg_pull_none>,
+					/* mac_txd1 */
+					<3 5 RK_FUNC_1 &pcfg_pull_none_13ma>,
+					/* mac_txd0 */
+					<3 4 RK_FUNC_1 &pcfg_pull_none_13ma>;
+			};
+		};
+
 		i2c0 {
 			i2c0_xfer: i2c0-xfer {
 				rockchip,pins =
-- 
1.9.1
