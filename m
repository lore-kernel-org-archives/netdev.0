From: Rami Rosen <ramirose@gmail.com>
Subject: [RFC PATCH net-next 1/3] ppp: remove NETIF_F_NETNS_LOCAL from ppp device features.
Date: Thu,  3 Jan 2013 11:25:19 +0200
Message-ID: <1357205121-4700-2-git-send-email-ramirose@gmail.com>
References: <1357205121-4700-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	shemminger@vyatta.com, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:49999 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752715Ab3ACJ0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 04:26:33 -0500
Received: by mail-ee0-f54.google.com with SMTP id c13so7190523eek.27
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2013 01:26:32 -0800 (PST)
In-Reply-To: <1357205121-4700-1-git-send-email-ramirose@gmail.com>
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
