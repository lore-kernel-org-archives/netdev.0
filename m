From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC v2 12/12] vti6: Enable namespace changing
Date: Wed, 5 Mar 2014 13:41:16 +0100
Message-ID: <1394023276-2591-13-git-send-email-steffen.klassert@secunet.com>
References: <1394023276-2591-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Christophe Gouault <christophe.gouault@6wind.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53210 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754423AbaCEMle (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 07:41:34 -0500
In-Reply-To: <1394023276-2591-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vti6 is now fully namespace aware, so allow namespace changing
for vti devices.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_vti.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 6085793..b7c0f82 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -803,7 +803,6 @@ static void vti6_dev_setup(struct net_device *dev)
 	t = netdev_priv(dev);
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
-	dev->features |= NETIF_F_NETNS_LOCAL;
 	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
 }
 
-- 
1.7.9.5
