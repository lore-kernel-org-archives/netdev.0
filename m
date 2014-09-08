From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: fix skb_page_frag_refill() kerneldoc
Date: Mon, 08 Sep 2014 04:00:00 -0700
Message-ID: <1410174000.11872.94.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:54875 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752776AbaIHLAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 07:00:04 -0400
Received: by mail-pd0-f170.google.com with SMTP id r10so20609414pdi.15
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 04:00:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit d9b2938aabf7 ("net: attempt a single high order allocation)
I forgot to update kerneldoc, as @prio parameter was renamed to @gfp

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/sock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index d372b4bd3f99..9c3f823e76a9 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1866,7 +1866,7 @@ EXPORT_SYMBOL(sock_alloc_send_skb);
  * skb_page_frag_refill - check that a page_frag contains enough room
  * @sz: minimum size of the fragment we want to get
  * @pfrag: pointer to page_frag
- * @prio: priority for memory allocation
+ * @gfp: priority for memory allocation
  *
  * Note: While this allocator tries to use high order pages, there is
  * no guarantee that allocations succeed. Therefore, @sz MUST be
