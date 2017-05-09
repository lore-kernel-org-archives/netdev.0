From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH net-next] net: stmmac: use correct pointer when printing normal descriptor ring
Date: Tue, 9 May 2017 18:52:02 +0200
Message-ID: <20170509165202.19023-1-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Niklas Cassel <niklass@axis.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index cd8c60132390..a74c481401c4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3725,7 +3725,7 @@ static void sysfs_display_ring(void *head, int size, int extend_desc,
 			ep++;
 		} else {
 			seq_printf(seq, "%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
-				   i, (unsigned int)virt_to_phys(ep),
+				   i, (unsigned int)virt_to_phys(p),
 				   le32_to_cpu(p->des0), le32_to_cpu(p->des1),
 				   le32_to_cpu(p->des2), le32_to_cpu(p->des3));
 			p++;
-- 
2.11.0
