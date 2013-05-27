From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v9 06/11] ipv6: export in6addr_loopback to modules
Date: Mon, 27 May 2013 12:16:28 +0800
Message-ID: <1369628193-14925-7-git-send-email-amwang@redhat.com>
References: <1369628193-14925-1-git-send-email-amwang@redhat.com>
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5114 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032Ab3E0ERa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 00:17:30 -0400
In-Reply-To: <1369628193-14925-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

It is needed by vxlan module. Noticed by Mike.

Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv6/addrconf.c      |    9 ---------
 net/ipv6/addrconf_core.c |   10 ++++++++++
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 432e084..bdf0f614 100644
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
index 3807a79..cb991dd 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -100,3 +100,13 @@ EXPORT_SYMBOL(inet6addr_notifier_call_chain);
 
 const struct ipv6_stub *ipv6_stub __read_mostly;
 EXPORT_SYMBOL_GPL(ipv6_stub);
+
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
