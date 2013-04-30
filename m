From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v7 3/6] ipv6: export in6addr_loopback to modules
Date: Tue, 30 Apr 2013 16:43:12 +0800
Message-ID: <1367311395-15891-4-git-send-email-amwang@redhat.com>
References: <1367311395-15891-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39932 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759215Ab3D3Iny (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Apr 2013 04:43:54 -0400
In-Reply-To: <1367311395-15891-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

It is needed by vxlan module.

Cc: David S. Miller <davem@davemloft.net>
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv6/addrconf.c      |    9 ---------
 net/ipv6/addrconf_core.c |   10 ++++++++++
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d1ab6ab..650a109 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -238,15 +238,6 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
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
index 8c7cb63..8155cd2 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -98,5 +98,15 @@ int inet6addr_notifier_call_chain(unsigned long val, void *v)
 }
 EXPORT_SYMBOL(inet6addr_notifier_call_chain);
 
+/* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
+const struct in6_addr in6addr_loopback = IN6ADDR_LOOPBACK_INIT;
+EXPORT_SYMBOL(in6addr_loopback);
+const struct in6_addr in6addr_any = IN6ADDR_ANY_INIT;
+const struct in6_addr in6addr_linklocal_allnodes = IN6ADDR_LINKLOCAL_ALLNODES_INIT;
+const struct in6_addr in6addr_linklocal_allrouters = IN6ADDR_LINKLOCAL_ALLROUTERS_INIT;
+const struct in6_addr in6addr_interfacelocal_allnodes = IN6ADDR_INTERFACELOCAL_ALLNODES_INIT;
+const struct in6_addr in6addr_interfacelocal_allrouters = IN6ADDR_INTERFACELOCAL_ALLROUTERS_INIT;
+const struct in6_addr in6addr_sitelocal_allrouters = IN6ADDR_SITELOCAL_ALLROUTERS_INIT;
+
 const struct ipv6_mcast_ops *ipv6_mcast_ops __read_mostly;
 EXPORT_SYMBOL_GPL(ipv6_mcast_ops);
-- 
1.7.7.6
