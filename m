From: fgao@ikuai8.com
Subject: [PATCH 1/1] netfilter: udp: Only get 8 bytes header in udp_pkt_to_tuple to keep consistent with tcp_pkt_to_tuple and comments
Date: Thu, 21 Jul 2016 16:29:34 +0800
Message-ID: <1469089774-21818-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: pablo@netfilter.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG352.QQ.COM ([183.57.50.167]:41795 "EHLO smtpbg352.qq.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751558AbcGUIdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2016 04:33:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/netfilter/nf_conntrack_proto_udp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 4fd0405..a886a8a 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -45,7 +45,7 @@ static bool udp_pkt_to_tuple(const struct sk_buff *skb,
 	struct udphdr _hdr;
 
 	/* Actually only need first 8 bytes. */
-	hp = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
+	hp = skb_header_pointer(skb, dataoff, 8, &_hdr);
 	if (hp == NULL)
 		return false;
 
-- 
1.9.1
