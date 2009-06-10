From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/31: xtables: remove redundant casts
Date: Wed, 10 Jun 2009 21:46:27 +0200 (MEST)
Message-ID: <20090610194626.11112.54211.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33146 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760492AbZFJTq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 15:46:26 -0400
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ccf5bd8c27daa4184004438273e03d3812b14d75
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Apr 15 20:27:03 2009 +0200

    netfilter: xtables: remove redundant casts
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 5abc276..7fcbc16 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -280,7 +280,7 @@ static void trace_packet(struct sk_buff *skb,
 	char *hookname, *chainname, *comment;
 	unsigned int rulenum = 0;
 
-	table_base = (void *)private->entries[smp_processor_id()];
+	table_base = private->entries[smp_processor_id()];
 	root = get_entry(table_base, private->hook_entry[hook]);
 
 	hookname = chainname = (char *)hooknames[hook];
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 37a850e..2b52fac 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -312,7 +312,7 @@ static void trace_packet(struct sk_buff *skb,
 	char *hookname, *chainname, *comment;
 	unsigned int rulenum = 0;
 
-	table_base = (void *)private->entries[smp_processor_id()];
+	table_base = private->entries[smp_processor_id()];
 	root = get_entry(table_base, private->hook_entry[hook]);
 
 	hookname = chainname = (char *)hooknames[hook];
