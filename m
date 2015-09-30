From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 5/6] bridge: Remove br_nf_push_frag_xmit_sk
Date: Wed, 30 Sep 2015 16:25:35 -0500
Message-ID: <1443648336-31741-5-git-send-email-ebiederm@xmission.com>
References: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:45888 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932834AbbI3VeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 17:34:23 -0400
In-Reply-To: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that this compatability function no longer has any callers remove it.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/bridge/br_netfilter_hooks.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 815994d5b02d..370aa4d4cf4d 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -691,11 +691,6 @@ static int br_nf_push_frag_xmit(struct net *net, struct sock *sk, struct sk_buff
 	nf_bridge_info_free(skb);
 	return br_dev_queue_push_xmit(net, sk, skb);
 }
-static int br_nf_push_frag_xmit_sk(struct sock *sk, struct sk_buff *skb)
-{
-	struct net *net = dev_net(skb_dst(skb)->dev);
-	return br_nf_push_frag_xmit(net, sk, skb);
-}
 #endif
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
-- 
2.2.1
