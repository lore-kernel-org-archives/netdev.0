From: Rami Rosen <ramirose@gmail.com>
Subject: [RFC PATCH net-next 3/3] vxlan: remove NETIF_F_NETNS_LOCAL from vxlan device features.
Date: Thu,  3 Jan 2013 11:25:21 +0200
Message-ID: <1357205121-4700-4-git-send-email-ramirose@gmail.com>
References: <1357205121-4700-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	shemminger@vyatta.com, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:63061 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134Ab3ACJd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 04:33:56 -0500
Received: by mail-ee0-f50.google.com with SMTP id b45so7494251eek.23
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2013 01:33:55 -0800 (PST)
In-Reply-To: <1357205121-4700-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need for NETIF_F_NETNS_LOCAL for vxlan device; this patch removes it.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 drivers/net/vxlan.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 40f2cc1..385f743 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1185,7 +1185,6 @@ static void vxlan_setup(struct net_device *dev)
 
 	dev->tx_queue_len = 0;
 	dev->features	|= NETIF_F_LLTX;
-	dev->features	|= NETIF_F_NETNS_LOCAL;
 	dev->features	|= NETIF_F_SG | NETIF_F_HW_CSUM;
 	dev->features   |= NETIF_F_RXCSUM;
 
-- 
1.7.11.7
