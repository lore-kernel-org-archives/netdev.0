From: simran singhal <singhalsimran0@gmail.com>
Subject: [PATCH v2 1/2] netfilter: ipset: Compress return logic
Date: Tue, 21 Mar 2017 19:00:07 +0530
Message-ID: <1490103008-665-2-git-send-email-singhalsimran0@gmail.com>
References: <1490103008-665-1-git-send-email-singhalsimran0@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        gregkh@linuxfoundation.org, outreachy-kernel@googlegroups.com,
        wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490103008-665-1-git-send-email-singhalsimran0@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify function returns by merging assignment and return into one
command line.

Signed-off-by: simran singhal <singhalsimran0@gmail.com>
---

 --This is my contribution to the netfilter project of
   Outreachy Round 14.

 net/netfilter/ipset/ip_set_list_set.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 178d4eb..2fff6b5 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -453,7 +453,6 @@ static size_t
 list_set_memsize(const struct list_set *map, size_t dsize)
 {
 	struct set_elem *e;
-	size_t memsize;
 	u32 n = 0;
 
 	rcu_read_lock();
@@ -461,9 +460,7 @@ list_set_memsize(const struct list_set *map, size_t dsize)
 		n++;
 	rcu_read_unlock();
 
-	memsize = sizeof(*map) + n * dsize;
-
-	return memsize;
+	return (sizeof(*map) + n * dsize);
 }
 
 static int
-- 
2.7.4
