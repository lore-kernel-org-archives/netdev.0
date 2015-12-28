From: Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [RESEND PATCH v1 0/4] Add support emac for the RK3036 SoC platform
Date: Mon, 28 Dec 2015 15:22:17 +0800
Message-ID: <1451287341-16453-1-git-send-email-zhengxing@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org,
 Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>,
 Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
 keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
 leozwang-hpIqsD4AKlcxg7vii5yOFA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
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


Hi,
  We have supported the emac for RK3066/RK3188, but the RK3036 have some
configuration different with them. We should let the driver of emac_rockchip
compatible with other Rockchip SoCs.



Xing Zheng (4):
  net: ethernet: arc: Probe emac after set RMII clock
  net: ethernet: arc: Keep emac compatibility for more Rockchip SoCs
  net: ethernet: arc: Add support emac for RK3036
  ARM: dts: rockchip: Add support emac for RK3036

 arch/arm/boot/dts/rk3036-evb.dts         |   25 +++++++++
 arch/arm/boot/dts/rk3036-kylin.dts       |   23 ++++++++
 arch/arm/boot/dts/rk3036.dtsi            |   32 +++++++++++
 drivers/net/ethernet/arc/Kconfig         |    4 +-
 drivers/net/ethernet/arc/emac_rockchip.c |   86 ++++++++++++++++++++----------
 5 files changed, 140 insertions(+), 30 deletions(-)

-- 
1.7.9.5
