From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/3] netfilter: ipset: fix incorret comparison in hash_netnet4_data_equal()
Date: Sun,  8 Dec 2013 00:13:28 +0100
Message-ID: <1386458010-4615-2-git-send-email-pablo@netfilter.org>
References: <1386458010-4615-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1386458010-4615-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej@redhat.com>

Both sides of the comparison are the same, looks like a cut-and-paste error.

Spotted by Coverity.

Signed-off-by: Dave Jones <davej@fedoraproject.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_netnet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
index 2bc2dec..6226803 100644
--- a/net/netfilter/ipset/ip_set_hash_netnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -59,7 +59,7 @@ hash_netnet4_data_equal(const struct hash_netnet4_elem *ip1,
 		     u32 *multi)
 {
 	return ip1->ipcmp == ip2->ipcmp &&
-	       ip2->ccmp == ip2->ccmp;
+	       ip1->ccmp == ip2->ccmp;
 }
 
 static inline int
-- 
1.7.10.4

