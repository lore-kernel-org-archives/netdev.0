From: Lucas Tanure <tanure@linux.com>
Subject: [PATCH 2/4] netfilter: ipv4: EXPORT_SYMBOL should be shortly thereafter the exported function
Date: Sat, 30 Jan 2016 11:17:56 -0200
Message-ID: <1454159878-20706-2-git-send-email-tanure@linux.com>
References: <1454159878-20706-1-git-send-email-tanure@linux.com>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454159878-20706-1-git-send-email-tanure@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

change made to resolve following checkpatch message:
  WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable

Signed-off-by: Lucas Tanure <tanure@linux.com>
---
 net/ipv4/netfilter/ip_tables.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index aa0e41e..79d4a04 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -442,6 +442,7 @@ ipt_do_table(struct sk_buff *skb,
 	else return verdict;
 #endif
 }
+EXPORT_SYMBOL(ipt_do_table);
 
 /* Figures out from what hook each rule can be called: returns 0 if
    there are loops.  Puts hook bitmask in comefrom. */
@@ -2098,6 +2099,7 @@ out_free:
 out:
 	return ERR_PTR(ret);
 }
+EXPORT_SYMBOL(ipt_register_table);
 
 void ipt_unregister_table(struct net *net, struct xt_table *table)
 {
@@ -2116,6 +2118,7 @@ void ipt_unregister_table(struct net *net, struct xt_table *table)
 		module_put(table_owner);
 	xt_free_table_info(private);
 }
+EXPORT_SYMBOL(ipt_unregister_table);
 
 /* Returns 1 if the type and code is matched by the range, 0 otherwise */
 static inline bool
@@ -2269,8 +2272,5 @@ static void __exit ip_tables_fini(void)
 	unregister_pernet_subsys(&ip_tables_net_ops);
 }
 
-EXPORT_SYMBOL(ipt_register_table);
-EXPORT_SYMBOL(ipt_unregister_table);
-EXPORT_SYMBOL(ipt_do_table);
 module_init(ip_tables_init);
 module_exit(ip_tables_fini);
-- 
2.7.0
