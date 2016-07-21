From: fgao@ikuai8.com
Subject: [PATCH 1/1] netfilter: udp: Remove a bit misleading comment in udp_pkt_to_tuple
Date: Thu, 21 Jul 2016 17:26:47 +0800
Message-ID: <1469093207-5958-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: pablo@netfilter.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v1: Initial patch

 net/netfilter/nf_conntrack_proto_udp.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 4fd0405..bc8276b 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -44,7 +44,6 @@ static bool udp_pkt_to_tuple(const struct sk_buff *skb,
 	const struct udphdr *hp;
 	struct udphdr _hdr;
 
-	/* Actually only need first 8 bytes. */
 	hp = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
 	if (hp == NULL)
 		return false;
-- 
1.9.1


