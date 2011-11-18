From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH] xen-netback: use correct index for invalidation in xen_netbk_tx_check_gop()
Date: Fri, 18 Nov 2011 15:42:05 +0000
Message-ID: <1321630925-13652-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: xen-devel@lists.xensource.com, Jan Beulich <JBeulich@suse.com>,
	Jan Beulich <jbeulich@suse.com>,
	Ian Campbell <ian.campbell@citrix.com>, stable@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:29835 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756126Ab1KRPmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 10:42:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Beulich <JBeulich@suse.com>

Signed-off-by: Jan Beulich <jbeulich@suse.com>
Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: stable@vger.kernel.org
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
