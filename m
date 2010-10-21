From: kaber@trash.net
Subject: [PATCH 36/72] netfilter: xtables: remove unused defines
Date: Thu, 21 Oct 2010 17:19:23 +0200
Message-ID: <1287674399-31455-37-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60005 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898Ab0JUPUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:10 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter_arp/arp_tables.h  |    4 ----
 include/linux/netfilter_ipv4/ip_tables.h  |    4 ----
 include/linux/netfilter_ipv6/ip6_tables.h |    4 ----
 3 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/include/linux/netfilter_arp/arp_tables.h b/include/linux/netfilter_arp/arp_tables.h
index f02d574..adbf4bf 100644
--- a/include/linux/netfilter_arp/arp_tables.h
+++ b/include/linux/netfilter_arp/arp_tables.h
@@ -255,8 +255,6 @@ extern unsigned int arpt_do_table(struct sk_buff *skb,
 				  const struct net_device *out,
 				  struct xt_table *table);
 
-#define ARPT_ALIGN(s) XT_ALIGN(s)
-
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
 
@@ -275,8 +273,6 @@ compat_arpt_get_target(struct compat_arpt_entry *e)
 	return (void *)e + e->target_offset;
 }
 
-#define COMPAT_ARPT_ALIGN(s)	COMPAT_XT_ALIGN(s)
-
 #endif /* CONFIG_COMPAT */
 #endif /*__KERNEL__*/
 #endif /* _ARPTABLES_H */
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index d0fef0a..64a5d95 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -282,8 +282,6 @@ extern unsigned int ipt_do_table(struct sk_buff *skb,
 				 const struct net_device *out,
 				 struct xt_table *table);
 
-#define IPT_ALIGN(s) XT_ALIGN(s)
-
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
 
@@ -304,8 +302,6 @@ compat_ipt_get_target(struct compat_ipt_entry *e)
 	return (void *)e + e->target_offset;
 }
 
-#define COMPAT_IPT_ALIGN(s) 	COMPAT_XT_ALIGN(s)
-
 #endif /* CONFIG_COMPAT */
 #endif /*__KERNEL__*/
 #endif /* _IPTABLES_H */
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index dca1118..c9784f7 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -292,8 +292,6 @@ extern int ip6t_ext_hdr(u8 nexthdr);
 extern int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 			 int target, unsigned short *fragoff);
 
-#define IP6T_ALIGN(s) XT_ALIGN(s)
-
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
 
@@ -313,8 +311,6 @@ compat_ip6t_get_target(struct compat_ip6t_entry *e)
 	return (void *)e + e->target_offset;
 }
 
-#define COMPAT_IP6T_ALIGN(s)	COMPAT_XT_ALIGN(s)
-
 #endif /* CONFIG_COMPAT */
 #endif /*__KERNEL__*/
 #endif /* _IP6_TABLES_H */
-- 
1.7.1

