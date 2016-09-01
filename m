From: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [PATCH v4 0/6] Support the rk3399 gmac and pd function
Date: Fri,  2 Sep 2016 01:49:58 +0800
Message-ID: <1472752204-8924-1-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
 Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>, Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
 Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>, Jianqun Xu <jay.xu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Brian Norris <briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 Shunqian Zheng <zhengsq-TNX95d0MmH7DzftRWevZcw@public.gmane.org>, Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Huang Tao <huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Elaine Zhang <zhangqing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
 Frank Wang <frank.wang-TNX95d0MmH7DzftRWevZcw@public.gmane.org>, dbasehore-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
 Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Douglas Anderson <dianders@chromium.
To: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
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

This patch have the following changes:

7edf13e net: stmmac: dwmac-rk: add rk3366 & rk3399 specific data
26e004e net: stmmac: dwmac-rk: fixes the gmac resume after PD on/off
b216c2f net: stmmac: dwmac-rk: add pd_gmac support for rk3399
848bb71 arm64: dts: rockchip: add the gmac power domain on rk3399
508e41f arm64: dts: rockchip: add the gmac needed node for rk3399
fb26795 arm64: dts: rockchip: enable the gmac for rk3399 evb board

Hi David,
The patch 1,2,3 is related to the rockchip net/stammc driver,

Hi Heiko,
The patch 4,5,6 is related to the dts changes.

The History version:

v1: https://lkml.org/lkml/2016/8/30/668
v2: https://lkml.org/lkml/2016/8/31/27
v3: https://lkml.org/lkml/2016/8/31/981

Thanks your reviewing!

-
Caesar


Changes in v4:
- Fixes from the original patch on https://patchwork.kernel.org/patch/9274557/
- remove the Roger signed-off for domain patch.
- The Roger had posted patch on https://patchwork.kernel.org/patch/9274561/.
- re-fixup to original author.

Changes in v3:
- leave into two patches based on patchv2, and fix nits and commit, as
  comment on https://patchwork.kernel.org/patch/9306339/
- generate a patch from https://patchwork.kernel.org/patch/9306339/.

Changes in v2:
- rk_gmac_powerup instead of the rk_gmac_init.
- fixes the build error on next kernel.
- Fixes the order, ss Heiko commnets on
  https://patchwork.kernel.org/patch/9305991/

Caesar Wang (1):
  arm64: dts: rockchip: add the gmac power domain on rk3399

David Wu (1):
  net: stmmac: dwmac-rk: add pd_gmac support for rk3399

Roger Chen (4):
  net: stmmac: dwmac-rk: add rk3366 & rk3399 specific data
  net: stmmac: dwmac-rk: fixes the gmac resume after PD on/off
  arm64: dts: rockchip: add the gmac needed node for rk3399
  arm64: dts: rockchip: enable the gmac for rk3399 evb board

 .../devicetree/bindings/net/rockchip-dwmac.txt     |   8 +-
 arch/arm64/boot/dts/rockchip/rk3399-evb.dts        |  31 +++
 arch/arm64/boot/dts/rockchip/rk3399.dtsi           |  90 ++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 254 ++++++++++++++++++++-
 4 files changed, 372 insertions(+), 11 deletions(-)

-- 
1.9.1
