From: Joe Perches <joe@perches.com>
Subject: [PATCH 18/39] drivers/net/wireless/iwlwifi: Update WARN uses
Date: Sat, 30 Oct 2010 14:08:35 -0700
Message-ID: <e95402f05ba92bbd0039505856641acf84dab981.1288471898.git.joe@perches.com>
References: <cover.1288471897.git.joe@perches.com>
Cc: Reinette Chatre <reinette.chatre@intel.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3744 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752162Ab0J3VJh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Oct 2010 17:09:37 -0400
In-Reply-To: <cover.1288471897.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Align arguments.
Add missing newlines.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c  |    3 +--
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c  |    6 +++---
 drivers/net/wireless/iwlwifi/iwl-tx.c       |    6 +++---
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    2 +-
 4 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
index b555edd..cbb63f3 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
@@ -2139,8 +2139,7 @@ static int iwl_get_idle_rx_chain_count(struct iwl_priv *priv, int active_cnt)
 	case IEEE80211_SMPS_OFF:
 		return active_cnt;
 	default:
-		WARN(1, "invalid SMPS mode %d",
-		     priv->current_ht_config.smps);
+		WARN(1, "invalid SMPS mode %d\n", priv->current_ht_config.smps);
 		return active_cnt;
 	}
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-sta.c b/drivers/net/wireless/iwlwifi/iwl-agn-sta.c
index 35a30d2..46c45e7 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-sta.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-sta.c
@@ -284,7 +284,7 @@ static int iwl_set_wep_dynamic_key_info(struct iwl_priv *priv,
 	 * in uCode. */
 
 	WARN(priv->stations[sta_id].sta.key.key_offset == WEP_INVALID_OFFSET,
-		"no space for a new key");
+	     "no space for a new key\n");
 
 	priv->stations[sta_id].sta.key.key_flags = key_flags;
 	priv->stations[sta_id].sta.sta.modify_mask = STA_MODIFY_KEY_MASK;
@@ -334,7 +334,7 @@ static int iwl_set_ccmp_dynamic_key_info(struct iwl_priv *priv,
 	 * in uCode. */
 
 	WARN(priv->stations[sta_id].sta.key.key_offset == WEP_INVALID_OFFSET,
-		"no space for a new key");
+	     "no space for a new key\n");
 
 	priv->stations[sta_id].sta.key.key_flags = key_flags;
 	priv->stations[sta_id].sta.sta.modify_mask = STA_MODIFY_KEY_MASK;
@@ -378,7 +378,7 @@ static int iwl_set_tkip_dynamic_key_info(struct iwl_priv *priv,
 	 * in uCode. */
 
 	WARN(priv->stations[sta_id].sta.key.key_offset == WEP_INVALID_OFFSET,
-		"no space for a new key");
+	     "no space for a new key\n");
 
 	priv->stations[sta_id].sta.key.key_flags = key_flags;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index 7261ee4..1d8c4a6 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -594,9 +594,9 @@ void iwl_tx_cmd_complete(struct iwl_priv *priv, struct iwl_rx_mem_buffer *rxb)
 	 * in the queue management code. */
 	if (WARN(txq_id != priv->cmd_queue,
 		 "wrong command queue %d (should be %d), sequence 0x%X readp=%d writep=%d\n",
-		  txq_id, priv->cmd_queue, sequence,
-		  priv->txq[priv->cmd_queue].q.read_ptr,
-		  priv->txq[priv->cmd_queue].q.write_ptr)) {
+		 txq_id, priv->cmd_queue, sequence,
+		 priv->txq[priv->cmd_queue].q.read_ptr,
+		 priv->txq[priv->cmd_queue].q.write_ptr)) {
 		iwl_print_hex_error(priv, pkt, 32);
 		return;
 	}
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 8f8c4b7..c89c409 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -168,7 +168,7 @@ static int iwl3945_set_ccmp_dynamic_key_info(struct iwl_priv *priv,
 	* in uCode. */
 
 	WARN(priv->stations[sta_id].sta.key.key_offset == WEP_INVALID_OFFSET,
-		"no space for a new key");
+	     "no space for a new key\n");
 
 	priv->stations[sta_id].sta.key.key_flags = key_flags;
 	priv->stations[sta_id].sta.sta.modify_mask = STA_MODIFY_KEY_MASK;
-- 
1.7.3.1.g432b3.dirty

