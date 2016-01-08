From: Xing Zheng <zhengxing@rock-chips.com>
Subject: [PATCH v2 0/3] Add support emac for the RK3036 SoC platform
Date: Fri,  8 Jan 2016 09:34:59 +0800
Message-ID: <1452216902-21063-1-git-send-email-zhengxing@rock-chips.com>
Cc: keescook@google.com, leozwang@google.com, heiko@sntech.de,
	davem@davemloft.net, netdev@vger.kernel.org,
	Xing Zheng <zhengxing@rock-chips.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-arm-kernel@lists.infradead.org
To: linux-rockchip@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,
  We have supported the emac for RK3066/RK3188, but the RK3036 have
some configuration different with them. We should let the driver of
emac_rockchip compatible with other Rockchip SoCs.

Changes in v2:
- Separate DTS from patch series.

Xing Zheng (3):
  net: ethernet: arc: Probe emac after set RMII clock
  net: ethernet: arc: Keep emac compatibility for more Rockchip SoCs
  net: ethernet: arc: Add support emac for RK3036

 drivers/net/ethernet/arc/Kconfig         |    4 +-
 drivers/net/ethernet/arc/emac_rockchip.c |   88 ++++++++++++++++++++----------
 2 files changed, 61 insertions(+), 31 deletions(-)

-- 
1.7.9.5
