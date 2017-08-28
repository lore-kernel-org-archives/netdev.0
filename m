From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] net: stmmac: constify clk_div_table
Date: Mon, 28 Aug 2017 11:22:20 +0530
Message-ID: <a54fe9764d287df370c16b0f0814d09d8fa24591.1503899422.git.arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: khilman@baylibre.com, carlo@caione.org, alexandre.torgue@st.com,
        peppe.cavallaro@st.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

clk_div_table are not supposed to change at runtime.
meson8b_dwmac structure is working with const clk_div_table.
So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
index 9685555..4404650b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
@@ -89,7 +89,7 @@ static int meson8b_init_clk(struct meson8b_dwmac *dwmac)
 	char clk_name[32];
 	const char *clk_div_parents[1];
 	const char *mux_parent_names[MUX_CLK_NUM_PARENTS];
-	static struct clk_div_table clk_25m_div_table[] = {
+	static const struct clk_div_table clk_25m_div_table[] = {
 		{ .val = 0, .div = 5 },
 		{ .val = 1, .div = 10 },
 		{ /* sentinel */ },
-- 
1.9.1
