From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/53] ipset: remove unused function __ip_set_get_netlink
Date: Mon,  1 May 2017 12:46:47 +0200
Message-ID: <1493635640-24325-21-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aaron Conole <aconole@bytheb.org>

There are no in-tree callers.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_core.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index cb120c3c040e..2b87d9fd3f72 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -501,14 +501,6 @@ __ip_set_put(struct ip_set *set)
  * a separate reference counter
  */
 static inline void
-__ip_set_get_netlink(struct ip_set *set)
-{
-	write_lock_bh(&ip_set_ref_lock);
-	set->ref_netlink++;
-	write_unlock_bh(&ip_set_ref_lock);
-}
-
-static inline void
 __ip_set_put_netlink(struct ip_set *set)
 {
 	write_lock_bh(&ip_set_ref_lock);
-- 
2.1.4

