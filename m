From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next 3/5] xfrm: checkpatch erros with space prohibited
Date: Thu, 19 Dec 2013 20:22:12 +0800
Message-ID: <1387455734-7624-4-git-send-email-chenweilong@huawei.com>
References: <1387455734-7624-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:60198 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755704Ab3LSMWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 07:22:35 -0500
In-Reply-To: <1387455734-7624-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Fix checkpatch error "space prohibited xxx".

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/xfrm/xfrm_policy.c | 6 +++---
 net/xfrm/xfrm_user.c   | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index e6f34de..ccf3063 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1699,7 +1699,7 @@ static int xfrm_expand_policies(const struct flowi *fl, u16 family,
 				xfrm_pols_put(pols, *num_pols);
 				return PTR_ERR(pols[1]);
 			}
-			(*num_pols) ++;
+			(*num_pols)++;
 			(*num_xfrms) += pols[1]->xfrm_nr;
 		}
 	}
@@ -2390,7 +2390,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	pol->curlft.use_time = get_seconds();
 
 	pols[0] = pol;
-	npols ++;
+	npols++;
 #ifdef CONFIG_XFRM_SUB_POLICY
 	if (pols[0]->type != XFRM_POLICY_TYPE_MAIN) {
 		pols[1] = xfrm_policy_lookup_bytype(net, XFRM_POLICY_TYPE_MAIN,
@@ -2402,7 +2402,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 				return 0;
 			}
 			pols[1]->curlft.use_time = get_seconds();
-			npols ++;
+			npols++;
 		}
 	}
 #endif
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index d998c7c..508de8f 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1833,7 +1833,7 @@ static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct net *net = sock_net(skb->sk);
 	struct xfrm_state *x;
 	struct km_event c;
-	int err = - EINVAL;
+	int err = -EINVAL;
 	u32 mark = 0;
 	struct xfrm_mark m;
 	struct xfrm_aevent_id *p = nlmsg_data(nlh);
-- 
1.7.12
