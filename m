From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: fix RFC5722 comment
Date: Mon, 30 Jan 2012 15:29:24 +0100
Message-ID: <1327933764.2288.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38027 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753167Ab2A3O32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 09:29:28 -0500
Received: by mail-bk0-f46.google.com with SMTP id s6so3216331bka.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 06:29:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC5722 Section 4 was amended by Errata 3089

Our implementation did the right thing anyway...

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/reassembly.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index b69fae7..9447bd6 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -336,12 +336,11 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	}
 
 found:
-	/* RFC5722, Section 4:
-	 *                                  When reassembling an IPv6 datagram, if
+	/* RFC5722, Section 4, amended by Errata ID : 3089
+	 *                          When reassembling an IPv6 datagram, if
 	 *   one or more its constituent fragments is determined to be an
 	 *   overlapping fragment, the entire datagram (and any constituent
-	 *   fragments, including those not yet received) MUST be silently
-	 *   discarded.
+	 *   fragments) MUST be silently discarded.
 	 */
 
 	/* Check for overlap with preceding fragment. */
