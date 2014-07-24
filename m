From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] netfilter: nf_conntrack: remove exceptional & on function
 name
Date: Fri, 25 Jul 2014 01:47:16 +0530
Message-ID: <20140724201716.GA16213@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:57516 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934176AbaGXUR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 16:17:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this file, function names are otherwise used as pointers without &.

A simplified version of the Coccinelle semantic patch that makes this
change is as follows: 

// <smpl>
@r@
identifier f;
@@

f(...) { ... }

@@
identifier r.f;
@@

- &f
+ f
// </smpl>

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 8127dc8..41744cd 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -358,7 +358,7 @@ static struct nf_sockopt_ops so_getorigdst = {
 	.pf		= PF_INET,
 	.get_optmin	= SO_ORIGINAL_DST,
 	.get_optmax	= SO_ORIGINAL_DST+1,
-	.get		= &getorigdst,
+	.get		= getorigdst,
 	.owner		= THIS_MODULE,
 };
 
-- 
1.9.1
