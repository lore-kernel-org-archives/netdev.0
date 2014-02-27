From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 12/12] vti4: Enable namespace changing
Date: Thu, 27 Feb 2014 09:00:40 +0100
Message-ID: <1393488040-22005-13-git-send-email-steffen.klassert@secunet.com>
References: <1393488040-22005-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:59058 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751326AbaB0IBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 03:01:03 -0500
In-Reply-To: <1393488040-22005-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vti4 is now fully namespace aware, so allow namespace changing
for vti devices

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_vti.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 9471893..687ddef 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -354,7 +354,6 @@ static int vti_tunnel_init(struct net_device *dev)
 	dev->flags		= IFF_NOARP;
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
-	dev->features		|= NETIF_F_NETNS_LOCAL;
 	dev->features		|= NETIF_F_LLTX;
 	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
 
-- 
1.7.9.5
