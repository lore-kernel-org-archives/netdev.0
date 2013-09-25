From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/11] mwifiex: Remove extern from function prototypes
Date: Wed, 25 Sep 2013 12:37:27 -0700
Message-ID: <b3a7cd194857b3dc099e8f8bb0ed97bb4a1b5fde.1380137610.git.joe@perches.com>
References: <cover.1380137609.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Bing Zhao <bzhao@marvell.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380137609.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/mwifiex/wmm.h | 24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/wmm.h b/drivers/net/wireless/mwifiex/wmm.h
index 644d6e0..0f129d4 100644
--- a/drivers/net/wireless/mwifiex/wmm.h
+++ b/drivers/net/wireless/mwifiex/wmm.h
@@ -83,11 +83,10 @@ mwifiex_wmm_is_ra_list_empty(struct list_head *ra_list_hhead)
 }
 
 void mwifiex_wmm_add_buf_txqueue(struct mwifiex_private *priv,
-					struct sk_buff *skb);
+				 struct sk_buff *skb);
 void mwifiex_ralist_add(struct mwifiex_private *priv, u8 *ra);
 void mwifiex_rotate_priolists(struct mwifiex_private *priv,
-			      struct mwifiex_ra_list_tbl *ra,
-			      int tid);
+			      struct mwifiex_ra_list_tbl *ra, int tid);
 
 int mwifiex_wmm_lists_empty(struct mwifiex_adapter *adapter);
 void mwifiex_wmm_process_tx(struct mwifiex_adapter *adapter);
@@ -95,21 +94,18 @@ int mwifiex_is_ralist_valid(struct mwifiex_private *priv,
 			    struct mwifiex_ra_list_tbl *ra_list, int tid);
 
 u8 mwifiex_wmm_compute_drv_pkt_delay(struct mwifiex_private *priv,
-					     const struct sk_buff *skb);
+				     const struct sk_buff *skb);
 void mwifiex_wmm_init(struct mwifiex_adapter *adapter);
 
-extern u32 mwifiex_wmm_process_association_req(struct mwifiex_private *priv,
-						 u8 **assoc_buf,
-						 struct ieee_types_wmm_parameter
-						 *wmmie,
-						 struct ieee80211_ht_cap
-						 *htcap);
+u32 mwifiex_wmm_process_association_req(struct mwifiex_private *priv,
+					u8 **assoc_buf,
+					struct ieee_types_wmm_parameter *wmmie,
+					struct ieee80211_ht_cap *htcap);
 
 void mwifiex_wmm_setup_queue_priorities(struct mwifiex_private *priv,
-					struct ieee_types_wmm_parameter
-					*wmm_ie);
+					struct ieee_types_wmm_parameter *wmm_ie);
 void mwifiex_wmm_setup_ac_downgrade(struct mwifiex_private *priv);
-extern int mwifiex_ret_wmm_get_status(struct mwifiex_private *priv,
-				      const struct host_cmd_ds_command *resp);
+int mwifiex_ret_wmm_get_status(struct mwifiex_private *priv,
+			       const struct host_cmd_ds_command *resp);
 
 #endif /* !_MWIFIEX_WMM_H_ */
-- 
1.8.1.2.459.gbcd45b4.dirty
