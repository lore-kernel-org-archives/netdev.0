From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/32] netfilter: ipset: Use MSEC_PER_SEC consistently
Date: Mon, 15 Jun 2015 23:26:10 +0200
Message-ID: <1434403589-24796-14-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set_timeout.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set_timeout.h b/include/linux/netfilter/ipset/ip_set_timeout.h
index 83c2f9e..3c8842b 100644
--- a/include/linux/netfilter/ipset/ip_set_timeout.h
+++ b/include/linux/netfilter/ipset/ip_set_timeout.h
@@ -61,7 +61,7 @@ ip_set_timeout_set(unsigned long *timeout, u32 t)
 		return;
 	}
 
-	*timeout = msecs_to_jiffies(t * 1000) + jiffies;
+	*timeout = msecs_to_jiffies(t * MSEC_PER_SEC) + jiffies;
 	if (*timeout == IPSET_ELEM_PERMANENT)
 		/* Bingo! :-) */
 		(*timeout)--;
@@ -71,7 +71,7 @@ static inline u32
 ip_set_timeout_get(unsigned long *timeout)
 {
 	return *timeout == IPSET_ELEM_PERMANENT ? 0 :
-		jiffies_to_msecs(*timeout - jiffies)/1000;
+		jiffies_to_msecs(*timeout - jiffies)/MSEC_PER_SEC;
 }
 
 #endif	/* __KERNEL__ */
-- 
1.7.10.4

