From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 2/2] datagram: fix kernel-doc comments
Date: Wed, 12 Jul 2017 09:29:07 -0700
Message-ID: <20170712162907.18465-3-sthemmin@microsoft.com>
References: <20170712162907.18465-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:32901 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753527AbdGLQ3T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 12:29:19 -0400
Received: by mail-pg0-f48.google.com with SMTP id k14so15606470pgr.0
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 09:29:19 -0700 (PDT)
In-Reply-To: <20170712162907.18465-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An underscore in the kernel-doc comment section has special meaning
and mis-use generates an errors.

./net/core/datagram.c:207: ERROR: Unknown target name: "msg".
./net/core/datagram.c:379: ERROR: Unknown target name: "msg".
./net/core/datagram.c:816: ERROR: Unknown target name: "t".

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/core/datagram.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index 6877c43cc92d..ee5647bd91b3 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -203,7 +203,7 @@ struct sk_buff *__skb_try_recv_from_queue(struct sock *sk,
 /**
  *	__skb_try_recv_datagram - Receive a datagram skbuff
  *	@sk: socket
- *	@flags: MSG_ flags
+ *	@flags: MSG\_ flags
  *	@destructor: invoked under the receive lock on successful dequeue
  *	@peeked: returns non-zero if this packet has been seen before
  *	@off: an offset in bytes to peek skb from. Returns an offset
@@ -375,7 +375,7 @@ EXPORT_SYMBOL(__sk_queue_drop_skb);
  *	skb_kill_datagram - Free a datagram skbuff forcibly
  *	@sk: socket
  *	@skb: datagram skbuff
- *	@flags: MSG_ flags
+ *	@flags: MSG\_ flags
  *
  *	This function frees a datagram skbuff that was received by
  *	skb_recv_datagram.  The flags argument must match the one
@@ -809,7 +809,7 @@ EXPORT_SYMBOL(skb_copy_and_csum_datagram_msg);
  *	sequenced packet sockets providing the socket receive queue
  *	is only ever holding data ready to receive.
  *
- *	Note: when you _don't_ use this routine for this protocol,
+ *	Note: when you *don't* use this routine for this protocol,
  *	and you use a different write policy from sock_writeable()
  *	then please supply your own write_space callback.
  */
-- 
2.11.0
