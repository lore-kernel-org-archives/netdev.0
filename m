From: Rami Rosen <ramirose@gmail.com>
Subject: [RFC PATCH v2 net-next 1/2] ppp: remove NETIF_F_NETNS_LOCAL from ppp device features.
Date: Mon,  7 Jan 2013 09:19:35 +0200
Message-ID: <1357543176-15352-2-git-send-email-ramirose@gmail.com>
References: <1357543176-15352-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	ebiederm@xmission.com, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:52246 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793Ab3AGHVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 02:21:10 -0500
Received: by mail-ee0-f49.google.com with SMTP id c4so9048367eek.22
        for <netdev@vger.kernel.org>; Sun, 06 Jan 2013 23:21:09 -0800 (PST)
In-Reply-To: <1357543176-15352-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need for NETIF_F_NETNS_LOCAL for ppp device; this patch removes it.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 drivers/net/ppp/ppp_generic.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 0b2706a..89b6fc5 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1073,7 +1073,6 @@ static void ppp_setup(struct net_device *dev)
 	dev->tx_queue_len = 3;
 	dev->type = ARPHRD_PPP;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
-	dev->features |= NETIF_F_NETNS_LOCAL;
 	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
 }
 
-- 
1.7.11.7
