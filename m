From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make struct ipv6_devconf static
Date: Tue, 22 Jul 2008 20:21:02 +0300
Message-ID: <20080722172102.GV14846@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:39684 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754597AbYGVRVN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 13:21:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct ipv6_devconf can now become static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 include/net/if_inet6.h |    2 --
 net/ipv6/addrconf.c    |    2 +-
 2 files changed, 1 insertion(+), 3 deletions(-)

60f8e80305011047545650fd718c1b33e27023eb 
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index db66c79..c8effa4 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -193,8 +193,6 @@ struct inet6_dev
 	struct rcu_head		rcu;
 };
 
-extern struct ipv6_devconf ipv6_devconf;
-
 static inline void ipv6_eth_mc_map(struct in6_addr *addr, char *buf)
 {
 	/*
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9f4fcce..74d543d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -153,7 +153,7 @@ static int ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 
 static ATOMIC_NOTIFIER_HEAD(inet6addr_chain);
 
-struct ipv6_devconf ipv6_devconf __read_mostly = {
+static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.forwarding		= 0,
 	.hop_limit		= IPV6_DEFAULT_HOPLIMIT,
 	.mtu6			= IPV6_MIN_MTU,

