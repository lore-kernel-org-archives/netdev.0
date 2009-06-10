From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 25/31: xt_NFQUEUE: use NFPROTO_UNSPEC
Date: Wed, 10 Jun 2009 21:46:53 +0200 (MEST)
Message-ID: <20090610194651.11112.25007.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 61f5abcab152cbee3a041f8b9bcfe7afc83409ca
Author: Florian Westphal <fw@strlen.de>
Date:   Fri Jun 5 13:18:07 2009 +0200

    netfilter: xt_NFQUEUE: use NFPROTO_UNSPEC
    
    We can use wildcard matching here, just like
    ab4f21e6fb1c09b13c4c3cb8357babe8223471bd ("xtables: use NFPROTO_UNSPEC
    in more extensions").
    
    Signed-off-by: Florian Westphal <fw@strlen.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index f9977b3..6e0f84d 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -34,21 +34,7 @@ nfqueue_tg(struct sk_buff *skb, const struct xt_target_param *par)
 static struct xt_target nfqueue_tg_reg[] __read_mostly = {
 	{
 		.name		= "NFQUEUE",
-		.family		= NFPROTO_IPV4,
-		.target		= nfqueue_tg,
-		.targetsize	= sizeof(struct xt_NFQ_info),
-		.me		= THIS_MODULE,
-	},
-	{
-		.name		= "NFQUEUE",
-		.family		= NFPROTO_IPV6,
-		.target		= nfqueue_tg,
-		.targetsize	= sizeof(struct xt_NFQ_info),
-		.me		= THIS_MODULE,
-	},
-	{
-		.name		= "NFQUEUE",
-		.family		= NFPROTO_ARP,
+		.family		= NFPROTO_UNSPEC,
 		.target		= nfqueue_tg,
 		.targetsize	= sizeof(struct xt_NFQ_info),
 		.me		= THIS_MODULE,
