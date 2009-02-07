From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/4] ipmr: use goto to common label instead of opencoding
Date: Sat,  7 Feb 2009 02:21:00 +0200
Message-ID: <1233966063-2419-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45958 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268AbZBGAVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 19:21:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/ipmr.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 21a6dc7..13e9dd3 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1243,8 +1243,7 @@ static void ipmr_queue_xmit(struct sk_buff *skb, =
struct mfc_cache *c, int vifi)
 		vif->dev->stats.tx_bytes +=3D skb->len;
 		vif->dev->stats.tx_packets++;
 		ipmr_cache_report(net, skb, vifi, IGMPMSG_WHOLEPKT);
-		kfree_skb(skb);
-		return;
+		goto out_free;
 	}
 #endif
=20
--=20
1.5.6.5

