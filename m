From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 04/11] ip6mr: use goto to common label instead of opencoding
Date: Sat, 13 Dec 2008 21:17:44 +0200
Message-ID: <12291958713600-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12291958711278-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229195871718-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958711089-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958711225-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45295 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228AbYLMTRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 14:17:55 -0500
In-Reply-To: <12291958711225-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv6/ip6mr.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 9eed242..3c51b2d 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1501,8 +1501,7 @@ static int ip6mr_forward2(struct sk_buff *skb, st=
ruct mfc6_cache *c, int vifi)
 		vif->dev->stats.tx_bytes +=3D skb->len;
 		vif->dev->stats.tx_packets++;
 		ip6mr_cache_report(net, skb, vifi, MRT6MSG_WHOLEPKT);
-		kfree_skb(skb);
-		return 0;
+		goto out_free;
 	}
 #endif
=20
--=20
1.5.2.2

