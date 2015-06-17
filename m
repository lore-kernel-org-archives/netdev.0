From: Heiko Stuebner <heiko@sntech.de>
Subject: [PATCH 0/4] net: stmmac: dwmac-rk: add support for rk3368
Date: Wed, 17 Jun 2015 23:54:42 +0200
Message-ID: <1434578086-12209-1-git-send-email-heiko@sntech.de>
Cc: roger.chen@rock-chips.com, linux-rockchip@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heiko Stuebner <heiko@sntech.de>
To: peppe.cavallaro@st.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Apart from small cleanups, this series provides support for the dwmac
on the new rk3368 ARM64 soc.

Tested on a R88 board using a RMII phy.

Heiko Stuebner (4):
  net: stmmac: dwmac-rk: remove unused gpio register defines
  net: stmmac: dwmac-rk: Fix clk rate when provided by soc
  net: stmmac: dwmac-rk: abstract access to mac settings in the GRF
  net: stmmac: dwmac-rk: add rk3368-specific data

 .../devicetree/bindings/net/rockchip-dwmac.txt     |   2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 248 +++++++++++++++++----
 2 files changed, 203 insertions(+), 47 deletions(-)

-- 
2.1.4
