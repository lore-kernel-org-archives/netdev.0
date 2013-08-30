From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: fix comment typo for __skb_alloc_pages()
Date: Fri, 30 Aug 2013 15:36:14 +0100
Message-ID: <1377873374-11350-1-git-send-email-f.fainelli@gmail.com>
References: <1377869297-19805-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, "Florian Fainelli" <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2996 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755636Ab3H3Og3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 10:36:29 -0400
In-Reply-To: <1377869297-19805-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The name of the function in the comment is __skb_alloc_page() while we
are actually commenting __skb_alloc_pages(). Fix this typo and make it
a valid kernel doc comment.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/skbuff.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5ac96f3..6f1330a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1905,8 +1905,8 @@ static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
 	return __netdev_alloc_skb_ip_align(dev, length, GFP_ATOMIC);
 }
 
-/*
- *	__skb_alloc_page - allocate pages for ps-rx on a skb and preserve pfmemalloc data
+/**
+ *	__skb_alloc_pages - allocate pages for ps-rx on a skb and preserve pfmemalloc data
  *	@gfp_mask: alloc_pages_node mask. Set __GFP_NOMEMALLOC if not for network packet RX
  *	@skb: skb to set pfmemalloc on if __GFP_MEMALLOC is used
  *	@order: size of the allocation
-- 
1.8.1.2
