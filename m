From: Joe Perches <joe@perches.com>
Subject: [PATCH net-2.6.25 5/8] net/netfilter: Use ipv4_is_<type>
Date: Thu, 13 Dec 2007 15:38:58 -0800
Message-ID: <1197589141-7020-5-git-send-email-joe@perches.com>
References: <1197589141-7020-1-git-send-email-joe@perches.com>
 <1197589141-7020-2-git-send-email-joe@perches.com>
 <1197589141-7020-3-git-send-email-joe@perches.com>
 <1197589141-7020-4-git-send-email-joe@perches.com>
Cc: Patrick McHardy <kaber@trash.net>, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4214 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759599AbXLMXjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 18:39:09 -0500
In-Reply-To: <1197589141-7020-4-git-send-email-joe@perches.com>
Message-Id: <350bda1cfd4ac57b354451157b9009b3c8ce334e.1197432867.git.joe@perches.com>
In-Reply-To: <e2ebcbf24539c0a3ef2ac77147dbfa55d8ac9e33.1197432867.git.joe@perches.com>
References: <e2ebcbf24539c0a3ef2ac77147dbfa55d8ac9e33.1197432867.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/netfilter/xt_pkttype.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/xt_pkttype.c b/net/netfilter/xt_pkttype.c
index c598bbe..2762449 100644
--- a/net/netfilter/xt_pkttype.c
+++ b/net/netfilter/xt_pkttype.c
@@ -31,7 +31,7 @@ pkttype_mt(const struct sk_buff *skb, const struct net_device *in,
 	const struct xt_pkttype_info *info = matchinfo;
 
 	if (skb->pkt_type == PACKET_LOOPBACK)
-		type = MULTICAST(ip_hdr(skb)->daddr)
+		type = ipv4_is_multicast(ip_hdr(skb)->daddr)
 			? PACKET_MULTICAST
 			: PACKET_BROADCAST;
 	else
-- 
1.5.3.7.949.g2221a6

