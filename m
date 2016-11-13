From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 23/39] netfilter: ipset: Regroup ip_set_put_extensions and add extern
Date: Sun, 13 Nov 2016 23:25:17 +0100
Message-ID: <1479075933-4491-24-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Cleanup: group ip_set_put_extensions and ip_set_get_extensions
together and add missing extern.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index b5bd0fb3d07b..7a218eb74887 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -331,6 +331,8 @@ extern size_t ip_set_elem_len(struct ip_set *set, struct nlattr *tb[],
 			      size_t len, size_t align);
 extern int ip_set_get_extensions(struct ip_set *set, struct nlattr *tb[],
 				 struct ip_set_ext *ext);
+extern int ip_set_put_extensions(struct sk_buff *skb, const struct ip_set *set,
+				 const void *e, bool active);
 
 static inline int
 ip_set_get_hostipaddr4(struct nlattr *nla, u32 *ipaddr)
@@ -449,10 +451,6 @@ bitmap_bytes(u32 a, u32 b)
 #include <linux/netfilter/ipset/ip_set_counter.h>
 #include <linux/netfilter/ipset/ip_set_skbinfo.h>
 
-int
-ip_set_put_extensions(struct sk_buff *skb, const struct ip_set *set,
-		      const void *e, bool active);
-
 #define IP_SET_INIT_KEXT(skb, opt, set)			\
 	{ .bytes = (skb)->len, .packets = 1,		\
 	  .timeout = ip_set_adt_opt_timeout(opt, set) }
-- 
2.1.4

