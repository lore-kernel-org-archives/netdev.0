From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: fix two typos in skbuff.h
Date: Tue, 01 May 2012 09:29:16 +0200
Message-ID: <1335857356.11396.31.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:49705 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917Ab2EAH3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 03:29:21 -0400
Received: by wgbds11 with SMTP id ds11so2975547wgb.1
        for <netdev@vger.kernel.org>; Tue, 01 May 2012 00:29:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

fix kernel doc typos in function names

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 775292a..111f26b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1020,7 +1020,7 @@ static inline void skb_queue_splice(const struct sk_buff_head *list,
 }
 
 /**
- *	skb_queue_splice - join two skb lists and reinitialise the emptied list
+ *	skb_queue_splice_init - join two skb lists and reinitialise the emptied list
  *	@list: the new list to add
  *	@head: the place to add it in the first list
  *
@@ -1051,7 +1051,7 @@ static inline void skb_queue_splice_tail(const struct sk_buff_head *list,
 }
 
 /**
- *	skb_queue_splice_tail - join two skb lists and reinitialise the emptied list
+ *	skb_queue_splice_tail_init - join two skb lists and reinitialise the emptied list
  *	@list: the new list to add
  *	@head: the place to add it in the first list
  *
