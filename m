From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 15/16] net: stmmac: remove unused variable in sysfs_display_ring
Date: Wed,  8 Feb 2017 09:31:20 +0100
Message-ID: <20170208083121.27949-16-clabbe.montjoie@gmail.com>
References: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Cc: linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The u64 x variable in sysfs_display_ring is unused.
This patch remove it.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c5dc3f9..d1b2e1e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2893,9 +2893,7 @@ static void sysfs_display_ring(void *head, int size, int extend_desc,
 	struct dma_desc *p = (struct dma_desc *)head;
 
 	for (i = 0; i < size; i++) {
-		u64 x;
 		if (extend_desc) {
-			x = *(u64 *) ep;
 			seq_printf(seq, "%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
 				   i, (unsigned int)virt_to_phys(ep),
 				   le32_to_cpu(ep->basic.des0),
@@ -2904,7 +2902,6 @@ static void sysfs_display_ring(void *head, int size, int extend_desc,
 				   le32_to_cpu(ep->basic.des3));
 			ep++;
 		} else {
-			x = *(u64 *) p;
 			seq_printf(seq, "%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
 				   i, (unsigned int)virt_to_phys(ep),
 				   le32_to_cpu(p->des0), le32_to_cpu(p->des1),
-- 
2.10.2
