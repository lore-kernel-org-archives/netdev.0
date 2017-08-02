From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH v3 04/11] net: stmmac: dwmac-rk: Remove unwanted code for rk3328_set_to_rmii()
Date: Wed,  2 Aug 2017 14:15:39 +0800
Message-ID: <1501654546-17292-5-git-send-email-david.wu@rock-chips.com>
References: <1501654546-17292-1-git-send-email-david.wu@rock-chips.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Wu <david.wu@rock-chips.com>
To: davem@davemloft.net, heiko@sntech.de, andrew@lunn.ch,
        f.fainelli@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com, olof@lixom.net,
        linux@armlinux.org.uk, arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501654546-17292-1-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is wrong setting for rk3328_set_to_rmii(), so remove it.

Signed-off-by: David Wu <david.wu@rock-chips.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index f0df519..a8e8fd5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -365,9 +365,6 @@ static void rk3328_set_to_rmii(struct rk_priv_data *bsp_priv)
 	regmap_write(bsp_priv->grf, RK3328_GRF_MAC_CON1,
 		     RK3328_GMAC_PHY_INTF_SEL_RMII |
 		     RK3328_GMAC_RMII_MODE);
-
-	/* set MAC to RMII mode */
-	regmap_write(bsp_priv->grf, RK3328_GRF_MAC_CON1, GRF_BIT(11));
 }
 
 static void rk3328_set_rgmii_speed(struct rk_priv_data *bsp_priv, int speed)
-- 
1.9.1
