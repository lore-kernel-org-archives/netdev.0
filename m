From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH 4/8] net/ipv6/exthdrs.c: Checkpatch cleanups
Date: Sun,  1 Apr 2012 19:49:04 +0200
Message-ID: <1333302548-9187-4-git-send-email-eldad@fogrefinery.com>
References: <1333302548-9187-1-git-send-email-eldad@fogrefinery.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eldad Zack <eldad@fogrefinery.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333302548-9187-1-git-send-email-eldad@fogrefinery.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

exthdrs.c:726: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
exthdrs.c:741: ERROR: "(foo*)" should be "(foo *)"
exthdrs.c:741: ERROR: "(foo*)" should be "(foo *)"
exthdrs.c:744: ERROR: "(foo**)" should be "(foo **)"
exthdrs.c:746: ERROR: "(foo**)" should be "(foo **)"
exthdrs.c:748: ERROR: "(foo**)" should be "(foo **)"
exthdrs.c:750: ERROR: "(foo**)" should be "(foo **)"
exthdrs.c:755: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
exthdrs.c:896: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 net/ipv6/exthdrs.c |   13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 3d641b6..c486b8e 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -722,7 +722,6 @@ void ipv6_push_nfrag_opts(struct sk_buff *skb, struct ipv6_txoptions *opt,
 	if (opt->hopopt)
 		ipv6_push_exthdr(skb, proto, NEXTHDR_HOP, opt->hopopt);
 }
-
 EXPORT_SYMBOL(ipv6_push_nfrag_opts);
 
 void ipv6_push_frag_opts(struct sk_buff *skb, struct ipv6_txoptions *opt, u8 *proto)
@@ -738,20 +737,19 @@ ipv6_dup_options(struct sock *sk, struct ipv6_txoptions *opt)
 
 	opt2 = sock_kmalloc(sk, opt->tot_len, GFP_ATOMIC);
 	if (opt2) {
-		long dif = (char*)opt2 - (char*)opt;
+		long dif = (char *)opt2 - (char *)opt;
 		memcpy(opt2, opt, opt->tot_len);
 		if (opt2->hopopt)
-			*((char**)&opt2->hopopt) += dif;
+			*((char **)&opt2->hopopt) += dif;
 		if (opt2->dst0opt)
-			*((char**)&opt2->dst0opt) += dif;
+			*((char **)&opt2->dst0opt) += dif;
 		if (opt2->dst1opt)
-			*((char**)&opt2->dst1opt) += dif;
+			*((char **)&opt2->dst1opt) += dif;
 		if (opt2->srcrt)
-			*((char**)&opt2->srcrt) += dif;
+			*((char **)&opt2->srcrt) += dif;
 	}
 	return opt2;
 }
-
 EXPORT_SYMBOL_GPL(ipv6_dup_options);
 
 static int ipv6_renew_option(void *ohdr,
@@ -892,5 +890,4 @@ struct in6_addr *fl6_update_dst(struct flowi6 *fl6,
 	fl6->daddr = *((struct rt0_hdr *)opt->srcrt)->addr;
 	return orig;
 }
-
 EXPORT_SYMBOL_GPL(fl6_update_dst);
-- 
1.7.9.5
