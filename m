From: Jeffrin Jose <ahiliation@yahoo.co.in>
Subject: [PATCH 1/4]net:ipv6:fixed a space issue relating to != operator
Date: Tue, 22 May 2012 00:33:35 +0530
Message-ID: <1337627015-3278-1-git-send-email-ahiliation@yahoo.co.in>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ahiliation@yahoo.co.in
To: davem@davemloft.net, edumazet@google.com, loke.chetan@gmail.com,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm20-vm0.bullet.mail.bf1.yahoo.com ([98.139.213.165]:21084 "HELO
	nm20-vm0.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753773Ab2EUTF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2012 15:05:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed a space issue relating to != operator
found by checkpatch.pl tool in net/ipv6/mcast.c

Signed-off-by: Jeffrin Jose <ahiliation@yahoo.co.in>
---
 net/ipv6/mcast.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 7dfb89f..8f7eee9 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -214,7 +214,7 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	spin_lock(&ipv6_sk_mc_lock);
 	for (lnk = &np->ipv6_mc_list;
 	     (mc_lst = rcu_dereference_protected(*lnk,
-			lockdep_is_held(&ipv6_sk_mc_lock))) !=NULL ;
+			lockdep_is_held(&ipv6_sk_mc_lock))) != NULL ;
 	      lnk = &mc_lst->next) {
 		if ((ifindex == 0 || mc_lst->ifindex == ifindex) &&
 		    ipv6_addr_equal(&mc_lst->addr, addr)) {
-- 
1.7.10
