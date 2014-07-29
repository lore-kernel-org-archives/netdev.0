From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 8/9] iwlegacy: use correct structure type name in sizeof
Date: Tue, 29 Jul 2014 17:16:50 +0200
Message-ID: <1406647011-8543-9-git-send-email-Julia.Lawall@lip6.fr>
References: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-ia64@vger.kernel.org,
	ceph-devel@vger.kernel.org, toralf.foerster@gmx.de, hmh@hmh.eng.br,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Correct typo in the name of the type given to sizeof.  Because it is the
size of a pointer that is wanted, the typo has no impact on compilation or
execution.

This problem was found using Coccinelle (http://coccinelle.lip6.fr/).  The
semantic patch used can be found in message 0 of this patch series.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wireless/iwlegacy/common.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/iwlegacy/common.c
index 03de746..2c4fa49 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -2980,7 +2980,8 @@ il_tx_queue_alloc(struct il_priv *il, struct il_tx_queue *txq, u32 id)
 	/* Driver ilate data, only for Tx (not command) queues,
 	 * not shared with device. */
 	if (id != il->cmd_queue) {
-		txq->skbs = kcalloc(TFD_QUEUE_SIZE_MAX, sizeof(struct skb *),
+		txq->skbs = kcalloc(TFD_QUEUE_SIZE_MAX,
+				    sizeof(struct sk_buff *),
 				    GFP_KERNEL);
 		if (!txq->skbs) {
 			IL_ERR("Fail to alloc skbs\n");

