From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH/TRIVIAL 1/1 net-next] ipv6: spelling s/incomming/incoming
Date: Wed, 29 Oct 2014 10:00:26 +0100
Message-ID: <1414573227-10743-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Kosina <trivial@kernel.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv6/ip6mr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 0171f08..467f310 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2090,7 +2090,7 @@ static void ip6_mr_forward(struct net *net, struct mr6_table *mrt,
 	if (ipv6_addr_any(&cache->mf6c_origin) && true_vifi >= 0) {
 		struct mfc6_cache *cache_proxy;
 
-		/* For an (*,G) entry, we only check that the incomming
+		/* For an (*,G) entry, we only check that the incoming
 		 * interface is part of the static tree.
 		 */
 		cache_proxy = ip6mr_cache_find_any_parent(mrt, vif);
-- 
1.9.3
