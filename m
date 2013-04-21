From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v5 3/5] ipv6: export in6addr_loopback to modules
Date: Sun, 21 Apr 2013 22:23:10 +0800
Message-ID: <1366554192-27887-4-git-send-email-amwang@redhat.com>
References: <1366554192-27887-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57318 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753606Ab3DUOYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Apr 2013 10:24:08 -0400
In-Reply-To: <1366554192-27887-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

It is needed by vxlan module.

Cc: David S. Miller <davem@davemloft.net>
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv6/addrconf.c      |    9 ---------
 net/ipv6/addrconf_core.c |    9 +++++++++
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 28b61e8..1aee907 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -240,15 +240,6 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.accept_dad		= 1,
 };
 
-/* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
-const struct in6_addr in6addr_any = IN6ADDR_ANY_INIT;
-const struct in6_addr in6addr_loopback = IN6ADDR_LOOPBACK_INIT;
-const struct in6_addr in6addr_linklocal_allnodes = IN6ADDR_LINKLOCAL_ALLNODES_INIT;
-const struct in6_addr in6addr_linklocal_allrouters = IN6ADDR_LINKLOCAL_ALLROUTERS_INIT;
-const struct in6_addr in6addr_interfacelocal_allnodes = IN6ADDR_INTERFACELOCAL_ALLNODES_INIT;
-const struct in6_addr in6addr_interfacelocal_allrouters = IN6ADDR_INTERFACELOCAL_ALLROUTERS_INIT;
-const struct in6_addr in6addr_sitelocal_allrouters = IN6ADDR_SITELOCAL_ALLROUTERS_INIT;
-
 /* Check if a valid qdisc is available */
 static inline bool addrconf_qdisc_ok(const struct net_device *dev)
 {
diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index d051e5f..d4bcc1d 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -78,3 +78,12 @@ int __ipv6_addr_type(const struct in6_addr *addr)
 }
 EXPORT_SYMBOL(__ipv6_addr_type);
 
+/* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
+const struct in6_addr in6addr_loopback = IN6ADDR_LOOPBACK_INIT;
+EXPORT_SYMBOL(in6addr_loopback);
+const struct in6_addr in6addr_any = IN6ADDR_ANY_INIT;
+const struct in6_addr in6addr_linklocal_allnodes = IN6ADDR_LINKLOCAL_ALLNODES_INIT;
+const struct in6_addr in6addr_linklocal_allrouters = IN6ADDR_LINKLOCAL_ALLROUTERS_INIT;
+const struct in6_addr in6addr_interfacelocal_allnodes = IN6ADDR_INTERFACELOCAL_ALLNODES_INIT;
+const struct in6_addr in6addr_interfacelocal_allrouters = IN6ADDR_INTERFACELOCAL_ALLROUTERS_INIT;
+const struct in6_addr in6addr_sitelocal_allrouters = IN6ADDR_SITELOCAL_ALLROUTERS_INIT;
-- 
1.7.7.6
