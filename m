From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH] xen-netback: use correct index for invalidation
	in netbk_tx_check_mop()
Date: Fri, 18 Nov 2011 14:13:19 +0000
Message-ID: <1321625599-3739-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, Ian Campbell <ian.campbell@citrix.com>,
	Jan Beulich <jbeulich@suse.com>
To: netdev@vger.kernel.org
Return-path: <xen-devel-bounces@lists.xensource.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

From: Jan Beulich <JBeulich@suse.com>

Signed-off-by: Jan Beulich <jbeulich@suse.com>
Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netback/netback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 0cb594c..1ae270e 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1021,7 +1021,7 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 		pending_idx = *((u16 *)skb->data);
 		xen_netbk_idx_release(netbk, pending_idx);
 		for (j = start; j < i; j++) {
-			pending_idx = frag_get_pending_idx(&shinfo->frags[i]);
+			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
 			xen_netbk_idx_release(netbk, pending_idx);
 		}
 
-- 
1.7.2.5
