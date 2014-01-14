From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 03/15] xfrm: checkpatch erros with space prohibited
Date: Tue, 14 Jan 2014 07:49:07 +0100
Message-ID: <1389682159-3260-4-git-send-email-steffen.klassert@secunet.com>
References: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60079 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752290AbaANGth (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 01:49:37 -0500
In-Reply-To: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Fix checkpatch error "space prohibited xxx".

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c |    6 +++---
 net/xfrm/xfrm_user.c   |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index dc8bd1b..fbc72b4 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1704,7 +1704,7 @@ static int xfrm_expand_policies(const struct flowi *fl, u16 family,
 				xfrm_pols_put(pols, *num_pols);
 				return PTR_ERR(pols[1]);
 			}
-			(*num_pols) ++;
+			(*num_pols)++;
 			(*num_xfrms) += pols[1]->xfrm_nr;
 		}
 	}
@@ -2378,7 +2378,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	pol->curlft.use_time = get_seconds();
 
 	pols[0] = pol;
-	npols ++;
+	npols++;
 #ifdef CONFIG_XFRM_SUB_POLICY
 	if (pols[0]->type != XFRM_POLICY_TYPE_MAIN) {
 		pols[1] = xfrm_policy_lookup_bytype(net, XFRM_POLICY_TYPE_MAIN,
@@ -2390,7 +2390,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 				return 0;
 			}
 			pols[1]->curlft.use_time = get_seconds();
-			npols ++;
+			npols++;
 		}
 	}
 #endif
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index e50be42..3348566 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1824,7 +1824,7 @@ static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct net *net = sock_net(skb->sk);
 	struct xfrm_state *x;
 	struct km_event c;
-	int err = - EINVAL;
+	int err = -EINVAL;
 	u32 mark = 0;
 	struct xfrm_mark m;
 	struct xfrm_aevent_id *p = nlmsg_data(nlh);
-- 
1.7.9.5
