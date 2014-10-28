From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCH 2/2] xen-netback: Remove __GFP_COLD
Date: Tue, 28 Oct 2014 15:29:31 +0000
Message-ID: <1414510171-12853-3-git-send-email-david.vrabel@citrix.com>
References: <1414510171-12853-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"Zoltan Kiss" <zoltan.kiss@linaro.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:29705 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbaJ1PaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 11:30:17 -0400
In-Reply-To: <1414510171-12853-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zoltan Kiss <zoltan.kiss@linaro.org>

This flag is unnecessary, it came from some old code.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Zoltan Kiss <zoltan.kiss@linaro.org>
Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/netback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 25f4c06..730252c 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1550,7 +1550,7 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
 		unsigned int len;
 
 		BUG_ON(i >= MAX_SKB_FRAGS);
-		page = alloc_page(GFP_ATOMIC|__GFP_COLD);
+		page = alloc_page(GFP_ATOMIC);
 		if (!page) {
 			int j;
 			skb->truesize += skb->data_len;
-- 
1.7.10.4
