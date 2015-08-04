From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/18] netfilter: xtables: remove __pure annotation
Date: Tue,  4 Aug 2015 12:02:40 +0200
Message-ID: <1438682568-8346-11-git-send-email-pablo@netfilter.org>
References: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56041 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933120AbbHDJ5b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 05:57:31 -0400
In-Reply-To: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

sparse complains:
ip_tables.c:361:27: warning: incorrect type in assignment (different modifiers)
ip_tables.c:361:27:    expected struct ipt_entry *[assigned] e
ip_tables.c:361:27:    got struct ipt_entry [pure] *

doesn't change generated code.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/arp_tables.c |    2 +-
 net/ipv4/netfilter/ip_tables.c  |    2 +-
 net/ipv6/netfilter/ip6_tables.c |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 969fdbe..c416cb3 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -240,7 +240,7 @@ get_entry(const void *base, unsigned int offset)
 	return (struct arpt_entry *)(base + offset);
 }
 
-static inline __pure
+static inline
 struct arpt_entry *arpt_next_entry(const struct arpt_entry *entry)
 {
 	return (void *)entry + entry->next_offset;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index ff585bd..787f99e 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -276,7 +276,7 @@ static void trace_packet(const struct sk_buff *skb,
 }
 #endif
 
-static inline __pure
+static inline
 struct ipt_entry *ipt_next_entry(const struct ipt_entry *entry)
 {
 	return (void *)entry + entry->next_offset;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index ea6d105..4e21f80 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -305,7 +305,7 @@ static void trace_packet(const struct sk_buff *skb,
 }
 #endif
 
-static inline __pure struct ip6t_entry *
+static inline struct ip6t_entry *
 ip6t_next_entry(const struct ip6t_entry *entry)
 {
 	return (void *)entry + entry->next_offset;
-- 
1.7.10.4
