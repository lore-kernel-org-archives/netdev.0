From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 01/20] net: stmmac: export stmmac_set_mac_addr/stmmac_get_mac_addr
Date: Mon,  3 Apr 2017 11:14:25 +0200
Message-ID: <20170403091444.29876-2-clabbe.montjoie@gmail.com>
References: <20170403091444.29876-1-clabbe.montjoie@gmail.com>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170403091444.29876-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thoses symbol will be needed for the dwmac-sun8i ethernet driver.
For letting it to be build as module, they need to be exported.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
index 38f9430..67af0bd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
@@ -248,6 +248,7 @@ void stmmac_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
 	data = (addr[3] << 24) | (addr[2] << 16) | (addr[1] << 8) | addr[0];
 	writel(data, ioaddr + low);
 }
+EXPORT_SYMBOL_GPL(stmmac_set_mac_addr);
 
 /* Enable disable MAC RX/TX */
 void stmmac_set_mac(void __iomem *ioaddr, bool enable)
@@ -279,4 +280,4 @@ void stmmac_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
 	addr[4] = hi_addr & 0xff;
 	addr[5] = (hi_addr >> 8) & 0xff;
 }
-
+EXPORT_SYMBOL_GPL(stmmac_get_mac_addr);
-- 
2.10.2
