From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/5] em_meta: fix sparse warning
Date: Wed, 23 Feb 2011 11:06:52 -0800
Message-ID: <20110223190701.242668793@vyatta.com>
References: <20110223190647.482444598@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:44644 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753041Ab1BWTxA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 14:53:00 -0500
Content-Disposition: inline; filename=em-meta-sparse
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gfp_t needs to be cast to integer.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/sched/em_meta.c	2011-02-23 10:26:17.534042646 -0800
+++ b/net/sched/em_meta.c	2011-02-23 10:30:37.533063770 -0800
@@ -401,7 +401,7 @@ META_COLLECTOR(int_sk_sndbuf)
 META_COLLECTOR(int_sk_alloc)
 {
 	SKIP_NONLOCAL(skb);
-	dst->value = skb->sk->sk_allocation;
+	dst->value = (__force int) skb->sk->sk_allocation;
 }
 
 META_COLLECTOR(int_sk_route_caps)


