From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 3/5] net: Fix first line of kernel-doc for a few functions
Date: Sun, 14 Feb 2010 14:19:14 +0000
Message-ID: <1266157154.10567.15.camel@localhost>
References: <1266157055.10567.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49856 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751566Ab0BNOTR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Feb 2010 09:19:17 -0500
In-Reply-To: <1266157055.10567.13.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function name must be followed by a space, hypen, space, and a
short description.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/skbuff.h |    4 ++--
 include/net/sock.h     |    2 +-
 net/sunrpc/rpc_pipe.c  |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ae836fd..ba0f8e3 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -738,7 +738,7 @@ static inline struct sk_buff *skb_unshare(struct sk_buff *skb,
 }
 
 /**
- *	skb_peek
+ *	skb_peek - peek at the head of an &sk_buff_head
  *	@list_: list to peek at
  *
  *	Peek an &sk_buff. Unlike most other operations you _MUST_
@@ -759,7 +759,7 @@ static inline struct sk_buff *skb_peek(struct sk_buff_head *list_)
 }
 
 /**
- *	skb_peek_tail
+ *	skb_peek_tail - peek at the tail of an &sk_buff_head
  *	@list_: list to peek at
  *
  *	Peek an &sk_buff. Unlike most other operations you _MUST_
diff --git a/include/net/sock.h b/include/net/sock.h
index c8d4000..580d51f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1049,7 +1049,7 @@ extern void sk_common_release(struct sock *sk);
 extern void sock_init_data(struct socket *sock, struct sock *sk);
 
 /**
- *	sk_filter_release: Release a socket filter
+ *	sk_filter_release - release a socket filter
  *	@fp: filter to remove
  *
  *	Remove a filter from a socket and release its resources.
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 9ac493f..8d63f8f 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -78,7 +78,7 @@ rpc_timeout_upcall_queue(struct work_struct *work)
 }
 
 /**
- * rpc_queue_upcall
+ * rpc_queue_upcall - queue an upcall message to userspace
  * @inode: inode of upcall pipe on which to queue given message
  * @msg: message to queue
  *
-- 
1.6.6.2



