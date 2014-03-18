From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 13/13] vti6: Enable namespace changing
Date: Tue, 18 Mar 2014 08:21:38 +0100
Message-ID: <1395127298-24083-14-git-send-email-steffen.klassert@secunet.com>
References: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53304 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753588AbaCRHWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:22:00 -0400
In-Reply-To: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
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
