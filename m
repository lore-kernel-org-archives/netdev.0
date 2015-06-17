From: Heiko Stuebner <heiko@sntech.de>
Subject: [PATCH 1/4] net: stmmac: dwmac-rk: remove unused gpio register defines
Date: Wed, 17 Jun 2015 23:54:43 +0200
Message-ID: <1434578086-12209-2-git-send-email-heiko@sntech.de>
References: <1434578086-12209-1-git-send-email-heiko@sntech.de>
Cc: roger.chen@rock-chips.com, linux-rockchip@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heiko Stuebner <heiko@sntech.de>
To: peppe.cavallaro@st.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434578086-12209-1-git-send-email-heiko@sntech.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In a first version the driver did want to do some gpio wiggling, which
of course never made it into the kernel, but somehow these register
defines where forgotten. Remove them, as they shouldn't be here.

Signed-off-by: Heiko Stuebner <heiko@sntech.de>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 30e28f0..49c7715 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -65,9 +65,6 @@ struct rk_priv_data {
 
 #define RK3288_GRF_SOC_CON1	0x0248
 #define RK3288_GRF_SOC_CON3	0x0250
-#define RK3288_GRF_GPIO3D_E	0x01ec
-#define RK3288_GRF_GPIO4A_E	0x01f0
-#define RK3288_GRF_GPIO4B_E	0x01f4
 
 /*RK3288_GRF_SOC_CON1*/
 #define GMAC_PHY_INTF_SEL_RGMII	(GRF_BIT(6) | GRF_CLR_BIT(7) | GRF_CLR_BIT(8))
-- 
2.1.4
