From: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH v2 0/4] net: stmmac: dwmac-rk: add support for rk3368
Date: Sun, 21 Jun 2015 21:52:50 +0200
Message-ID: <1434916374-7457-1-git-send-email-heiko@sntech.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
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

Apart from small cleanups, this series provides support for the dwmac
on the new rk3368 ARM64 soc.

Tested on a R88 board using a RMII phy.

Changes since v1:
- Adapt to changes resulting from patch d42202dce002 ("net: stmmac:
dwmac-rk: Don't add function name in info or err messages")


Heiko Stuebner (4):
  net: stmmac: dwmac-rk: remove unused gpio register defines
  net: stmmac: dwmac-rk: Fix clk rate when provided by soc
  net: stmmac: dwmac-rk: abstract access to mac settings in GRF
  net: stmmac: dwmac-rk: add rk3368-specific data

 .../devicetree/bindings/net/rockchip-dwmac.txt     |   2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 248 +++++++++++++++++----
 2 files changed, 203 insertions(+), 47 deletions(-)

-- 
2.1.4
