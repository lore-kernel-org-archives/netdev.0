From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/8] rxrpc: Delete unused rxrpc_kernel_free_skb()
Date: Wed, 07 Sep 2016 16:22:40 +0100
Message-ID: <147326176035.26593.15800039580252567510.stgit@warthog.procyon.org.uk>
References: <147326174610.26593.17043098689515647894.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48148 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757248AbcIGPWm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 11:22:42 -0400
In-Reply-To: <147326174610.26593.17043098689515647894.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delete rxrpc_kernel_free_skb() as it's unused.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/skbuff.c |   13 -------------
 1 file changed, 13 deletions(-)

diff --git a/net/rxrpc/skbuff.c b/net/rxrpc/skbuff.c
index 9752f8b1fdd0..a546a2ba6341 100644
--- a/net/rxrpc/skbuff.c
+++ b/net/rxrpc/skbuff.c
@@ -148,19 +148,6 @@ void rxrpc_packet_destructor(struct sk_buff *skb)
 	_leave("");
 }
 
-/**
- * rxrpc_kernel_free_skb - Free an RxRPC socket buffer
- * @skb: The socket buffer to be freed
- *
- * Let RxRPC free its own socket buffer, permitting it to maintain debug
- * accounting.
- */
-void rxrpc_kernel_free_skb(struct sk_buff *skb)
-{
-	rxrpc_free_skb(skb);
-}
-EXPORT_SYMBOL(rxrpc_kernel_free_skb);
-
 /*
  * Note the existence of a new-to-us socket buffer (allocated or dequeued).
  */
