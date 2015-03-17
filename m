From: Kevin Mulvey <kevin@kevinmulvey.net>
Subject: [PATCH] fix whitespace errors found by checkpatch.pl
Date: Tue, 17 Mar 2015 07:54:47 -0400
Message-ID: <1426593287-18619-1-git-send-email-kmulvey@linux.com>
Cc: Kevin Mulvey <kmulvey@linux.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

make checkpatch happier by fixing some whitespace
in ip6_tunnel.c and ip6_vti.c

Signed-off-by: Kevin Mulvey <kmulvey@linux.com>
---
 net/ipv6/ip6_tunnel.c | 2 +-
 net/ipv6/ip6_vti.c    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 266a264..892074a 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -250,7 +250,7 @@ ip6_tnl_link(struct ip6_tnl_net *ip6n, struct ip6_tnl *t)
 {
 	struct ip6_tnl __rcu **tp = ip6_tnl_bucket(ip6n, &t->parms);
 
-	rcu_assign_pointer(t->next , rtnl_dereference(*tp));
+	rcu_assign_pointer(t->next, rtnl_dereference(*tp));
 	rcu_assign_pointer(*tp, t);
 }
 
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 5fb9e21..48a6bc7 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -156,7 +156,7 @@ vti6_tnl_link(struct vti6_net *ip6n, struct ip6_tnl *t)
 {
 	struct ip6_tnl __rcu **tp = vti6_tnl_bucket(ip6n, &t->parms);
 
-	rcu_assign_pointer(t->next , rtnl_dereference(*tp));
+	rcu_assign_pointer(t->next, rtnl_dereference(*tp));
 	rcu_assign_pointer(*tp, t);
 }
 
-- 
2.1.0
