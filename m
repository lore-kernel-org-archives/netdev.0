From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v5 2/5] ipv6: export ipv6_sock_mc_join and ipv6_sock_mc_drop
Date: Sun, 21 Apr 2013 22:23:09 +0800
Message-ID: <1366554192-27887-3-git-send-email-amwang@redhat.com>
References: <1366554192-27887-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60837 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753709Ab3DUOX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Apr 2013 10:23:59 -0400
In-Reply-To: <1366554192-27887-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

They will be used by vxlan module.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv6/mcast.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index bfa6cc3..d03426d 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -200,6 +200,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 
 	return 0;
 }
+EXPORT_SYMBOL(ipv6_sock_mc_join);
 
 /*
  *	socket leave on multicast group
@@ -246,6 +247,7 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 
 	return -EADDRNOTAVAIL;
 }
+EXPORT_SYMBOL(ipv6_sock_mc_drop);
 
 /* called with rcu_read_lock() */
 static struct inet6_dev *ip6_mc_find_dev_rcu(struct net *net,
-- 
1.7.7.6
