From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/53] netfilter: ip6_tables: Remove unneccessary comments
Date: Mon,  1 May 2017 12:46:42 +0200
Message-ID: <1493635640-24325-16-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49766 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S378867AbdEAKry (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 06:47:54 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id B4EB91F4B9C
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:41 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A63C2FC3DC
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:41 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8E52FA6C1
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:39 +0200 (CEST)
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arushi Singhal <arushisinghal19971997@gmail.com>

This comments are obsolete and should go, as there are no set of rules
per CPU anymore.

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 net/ipv6/netfilter/ip6_tables.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index d862e3471935..1f90644056ac 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -51,15 +51,6 @@ void *ip6t_alloc_initial_table(const struct xt_table *info)
 }
 EXPORT_SYMBOL_GPL(ip6t_alloc_initial_table);
 
-/*
-   We keep a set of rules for each CPU, so we can avoid write-locking
-   them in the softirq when updating the counters and therefore
-   only need to read-lock in the softirq; doing a write_lock_bh() in user
-   context stops packets coming through and allows user context to read
-   the counters or update the rules.
-
-   Hence the start of any table is given by get_table() below.  */
-
 /* Returns whether matches rule or not. */
 /* Performance critical - called for every packet */
 static inline bool
-- 
2.1.4
