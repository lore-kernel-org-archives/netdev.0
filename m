From: Chaehyun Lim <chaehyun.lim@gmail.com>
Subject: [PATCH] ath10k: remove unused variable ar_pci
Date: Mon,  5 Sep 2016 22:38:02 +0900
Message-ID: <20160905133802.18755-1-chaehyun.lim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 Chaehyun Lim <chaehyun.lim@gmail.com>, ath10k@lists.infradead.org
To: kvalo@qca.qualcomm.com
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Trival fix to remove unused variable ar_pci in ath10k_pci_tx_pipe_cleanup
when building with W=1:
drivers/net/wireless/ath/ath10k/pci.c:1696:21: warning: variable
'ar_pci' set but not used [-Wunused-but-set-variable]

Signed-off-by: Chaehyun Lim <chaehyun.lim@gmail.com>
---
 drivers/net/wireless/ath/ath10k/pci.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/pci.c b/drivers/net/wireless/ath/ath10k/pci.c
index 1b841ad..afd5ef7 100644
--- a/drivers/net/wireless/ath/ath10k/pci.c
+++ b/drivers/net/wireless/ath/ath10k/pci.c
@@ -1693,14 +1693,12 @@ static void ath10k_pci_rx_pipe_cleanup(struct ath10k_pci_pipe *pci_pipe)
 static void ath10k_pci_tx_pipe_cleanup(struct ath10k_pci_pipe *pci_pipe)
 {
 	struct ath10k *ar;
-	struct ath10k_pci *ar_pci;
 	struct ath10k_ce_pipe *ce_pipe;
 	struct ath10k_ce_ring *ce_ring;
 	struct sk_buff *skb;
 	int i;
 
 	ar = pci_pipe->hif_ce_state;
-	ar_pci = ath10k_pci_priv(ar);
 	ce_pipe = pci_pipe->ce_hdl;
 	ce_ring = ce_pipe->src_ring;
 
-- 
2.9.2
