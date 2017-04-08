From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH] net: ipv6: Remove unneccessary comments
Date: Sat, 8 Apr 2017 21:19:30 +0530
Message-ID: <20170408154930.GA6924@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This comments are obsolete and should go, as there are no set of rules per
CPU anymore.

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 net/ipv6/netfilter/ip6_tables.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 1e15c54fd5e2..e52234a111d6 100644
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
2.11.0

