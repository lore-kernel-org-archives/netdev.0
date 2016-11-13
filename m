From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/39] netfilter: ipset: Remove extra whitespaces in ip_set.h
Date: Sun, 13 Nov 2016 23:25:10 +0100
Message-ID: <1479075933-4491-17-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Remove unnecessary whitespaces.

Ported from a patch proposed by Sergey Popovich <popovich_sergei@mail.ua>.

Suggested-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 83b9a2e0d8d4..5b1fd090f34b 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -336,14 +336,15 @@ ip_set_update_counter(struct ip_set_counter *counter,
 
 static inline void
 ip_set_get_skbinfo(struct ip_set_skbinfo *skbinfo,
-		      const struct ip_set_ext *ext,
-		      struct ip_set_ext *mext, u32 flags)
+		   const struct ip_set_ext *ext,
+		   struct ip_set_ext *mext, u32 flags)
 {
-		mext->skbmark = skbinfo->skbmark;
-		mext->skbmarkmask = skbinfo->skbmarkmask;
-		mext->skbprio = skbinfo->skbprio;
-		mext->skbqueue = skbinfo->skbqueue;
+	mext->skbmark = skbinfo->skbmark;
+	mext->skbmarkmask = skbinfo->skbmarkmask;
+	mext->skbprio = skbinfo->skbprio;
+	mext->skbqueue = skbinfo->skbqueue;
 }
+
 static inline bool
 ip_set_put_skbinfo(struct sk_buff *skb, struct ip_set_skbinfo *skbinfo)
 {
-- 
2.1.4

