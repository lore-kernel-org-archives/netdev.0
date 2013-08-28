From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v10 04/11] ipv6: export some IPv6 special addresses to modules
Date: Wed, 28 Aug 2013 13:22:52 +0800
Message-ID: <1377667379-2315-5-git-send-email-amwang@redhat.com>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43117 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752669Ab3H1FX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 01:23:57 -0400
In-Reply-To: <1377667379-2315-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

It is needed by vxlan module. Noticed by Mike.

Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv6/addrconf.c      |    9 ---------
 net/ipv6/addrconf_core.c |   16 ++++++++++++++++
 2 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2d6d179..8e68466 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -243,15 +243,6 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
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
index 93b24c6..a864033 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -101,3 +101,19 @@ EXPORT_SYMBOL(inet6addr_notifier_call_chain);
 
 const struct ipv6_stub *ipv6_stub __read_mostly;
 EXPORT_SYMBOL_GPL(ipv6_stub);
+
+/* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
+const struct in6_addr in6addr_loopback = IN6ADDR_LOOPBACK_INIT;
+EXPORT_SYMBOL(in6addr_loopback);
+const struct in6_addr in6addr_any = IN6ADDR_ANY_INIT;
+EXPORT_SYMBOL(in6addr_any);
+const struct in6_addr in6addr_linklocal_allnodes = IN6ADDR_LINKLOCAL_ALLNODES_INIT;
+EXPORT_SYMBOL(in6addr_linklocal_allnodes);
+const struct in6_addr in6addr_linklocal_allrouters = IN6ADDR_LINKLOCAL_ALLROUTERS_INIT;
+EXPORT_SYMBOL(in6addr_linklocal_allrouters);
+const struct in6_addr in6addr_interfacelocal_allnodes = IN6ADDR_INTERFACELOCAL_ALLNODES_INIT;
+EXPORT_SYMBOL(in6addr_interfacelocal_allnodes);
+const struct in6_addr in6addr_interfacelocal_allrouters = IN6ADDR_INTERFACELOCAL_ALLROUTERS_INIT;
+EXPORT_SYMBOL(in6addr_interfacelocal_allrouters);
+const struct in6_addr in6addr_sitelocal_allrouters = IN6ADDR_SITELOCAL_ALLROUTERS_INIT;
+EXPORT_SYMBOL(in6addr_sitelocal_allrouters);
-- 
1.7.7.6
