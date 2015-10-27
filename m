From: Punit Vara <punitvara@gmail.com>
Subject: [RESEND PATCH 07/10] net: wireless: iwlegacy: Remove unneeded variable ret
Date: Wed, 28 Oct 2015 00:32:42 +0530
Message-ID: <1445972565-14963-7-git-send-email-punitvara@gmail.com>
References: <1445972565-14963-1-git-send-email-punitvara@gmail.com>
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Punit Vara <punitvara@gmail.com>
To: kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445972565-14963-1-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to the 3945-mac.c file that fixes up following warning
by coccicheck:

drivers/net/wireless/iwlegacy/3945-mac.c:247:5-8: Unneeded variable:
"ret". Return "- EOPNOTSUPP" on line 249

Return -EOPNOTSUPP directly instead of return using ret

Signed-off-by: Punit Vara <punitvara@gmail.com>
---
 drivers/net/wireless/iwlegacy/3945-mac.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c b/drivers/net/wireless/iwlegacy/3945-mac.c
index af1b3e6..ff4dc44 100644
--- a/drivers/net/wireless/iwlegacy/3945-mac.c
+++ b/drivers/net/wireless/iwlegacy/3945-mac.c
@@ -244,9 +244,7 @@ il3945_set_dynamic_key(struct il_priv *il, struct ieee80211_key_conf *keyconf,
 static int
 il3945_remove_static_key(struct il_priv *il)
 {
-	int ret = -EOPNOTSUPP;
-
-	return ret;
+	return -EOPNOTSUPP;
 }
 
 static int
@@ -529,7 +527,6 @@ il3945_tx_skb(struct il_priv *il,
 		if (unlikely(tid >= MAX_TID_COUNT))
 			goto drop;
 	}
-
 	/* Descriptor for chosen Tx queue */
 	txq = &il->txq[txq_id];
 	q = &txq->q;
-- 
2.5.3
