From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 2/9] net: Use SKB_WITH_OVERHEAD in build_skb
Date: Thu, 3 May 2012 15:56:04 +0100
Message-ID: <1336056971-7839-2-git-send-email-ian.campbell@citrix.com>
References: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:43303 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757315Ab2ECO7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 10:59:23 -0400
In-Reply-To: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/skbuff.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a056d7c..c60b603 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -263,7 +263,7 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 	if (!skb)
 		return NULL;
 
-	size -= SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	size = SKB_WITH_OVERHEAD(size);
 
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->truesize = SKB_TRUESIZE(size);
-- 
1.7.2.5
