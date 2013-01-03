From: Rami Rosen <ramirose@gmail.com>
Subject: [RFC PATCH net-next 2/3] bridge: remove NETIF_F_NETNS_LOCAL from bridge device features.
Date: Thu,  3 Jan 2013 11:25:20 +0200
Message-ID: <1357205121-4700-3-git-send-email-ramirose@gmail.com>
References: <1357205121-4700-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	shemminger@vyatta.com, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:61196 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134Ab3ACJdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 04:33:19 -0500
Received: by mail-ee0-f48.google.com with SMTP id b57so7471549eek.35
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2013 01:33:18 -0800 (PST)
In-Reply-To: <1357205121-4700-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need for NETIF_F_NETNS_LOCAL for bridge device; this patch removes it.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 net/bridge/br_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 7c78e26..59d9598 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -345,7 +345,7 @@ void br_dev_setup(struct net_device *dev)
 
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
 			NETIF_F_GSO_MASK | NETIF_F_HW_CSUM | NETIF_F_LLTX |
-			NETIF_F_NETNS_LOCAL | NETIF_F_HW_VLAN_TX;
+			NETIF_F_HW_VLAN_TX;
 	dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
 			   NETIF_F_GSO_MASK | NETIF_F_HW_CSUM |
 			   NETIF_F_HW_VLAN_TX;
-- 
1.7.11.7
