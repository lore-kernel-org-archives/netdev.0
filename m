From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 16/16] net: stmmac: replace unsigned by u32
Date: Wed,  8 Feb 2017 09:31:21 +0100
Message-ID: <20170208083121.27949-17-clabbe.montjoie@gmail.com>
References: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Cc: linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

checkpatch complains about two unsigned without type after.
Since the value return is u32, it is simpler to replace it by u32 instead
of "unsigned int"

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index d1b2e1e..7251871 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -187,7 +187,7 @@ static void print_pkt(unsigned char *buf, int len)
 
 static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
 {
-	unsigned avail;
+	u32 avail;
 
 	if (priv->dirty_tx > priv->cur_tx)
 		avail = priv->dirty_tx - priv->cur_tx - 1;
@@ -199,7 +199,7 @@ static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
 
 static inline u32 stmmac_rx_dirty(struct stmmac_priv *priv)
 {
-	unsigned dirty;
+	u32 dirty;
 
 	if (priv->dirty_rx <= priv->cur_rx)
 		dirty = priv->cur_rx - priv->dirty_rx;
-- 
2.10.2
