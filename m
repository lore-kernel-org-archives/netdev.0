From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] dccp: kerneldoc warning fixes
Date: Mon, 17 Nov 2014 21:51:21 +0100
Message-ID: <1416257481-5690-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	"David S. Miller" <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/dccp/feat.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index 9733ddb..1704948 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -478,7 +478,7 @@ static struct dccp_feat_entry *
  * @fn_list: feature-negotiation list to update
  * @feat: one of %dccp_feature_numbers
  * @local: whether local (1) or remote (0) @feat_num is meant
- * @needs_mandatory: whether to use Mandatory feature negotiation options
+ * @mandatory: whether to use Mandatory feature negotiation options
  * @fval: pointer to NN/SP value to be inserted (will be copied)
  */
 static int dccp_feat_push_change(struct list_head *fn_list, u8 feat, u8 local,
@@ -1050,7 +1050,7 @@ static u8 dccp_feat_prefer(u8 preferred_value, u8 *array, u8 array_len)
 
 /**
  * dccp_feat_reconcile  -  Reconcile SP preference lists
- *  @fval: SP list to reconcile into
+ *  @fv: SP list to reconcile into
  *  @arr: received SP preference list
  *  @len: length of @arr in bytes
  *  @is_server: whether this side is the server (and @fv is the server's list)
-- 
1.9.3
