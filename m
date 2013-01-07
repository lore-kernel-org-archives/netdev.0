From: Rami Rosen <ramirose@gmail.com>
Subject: [RFC PATCH v2 net-next 2/2] bridge: remove NETIF_F_NETNS_LOCAL from bridge device features.
Date: Mon,  7 Jan 2013 09:19:36 +0200
Message-ID: <1357543176-15352-3-git-send-email-ramirose@gmail.com>
References: <1357543176-15352-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	ebiederm@xmission.com, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:36780 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752882Ab3AGHVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 02:21:12 -0500
Received: by mail-ee0-f47.google.com with SMTP id e51so8989108eek.6
        for <netdev@vger.kernel.org>; Sun, 06 Jan 2013 23:21:11 -0800 (PST)
In-Reply-To: <1357543176-15352-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need for NETIF_F_NETNS_LOCAL for bridge device; this patch removes it.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 net/bridge/br_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index e1bc090..0f88d21 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -344,7 +344,7 @@ void br_dev_setup(struct net_device *dev)
 
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
 			NETIF_F_GSO_MASK | NETIF_F_HW_CSUM | NETIF_F_LLTX |
-			NETIF_F_NETNS_LOCAL | NETIF_F_HW_VLAN_TX;
+			NETIF_F_HW_VLAN_TX;
 	dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
 			   NETIF_F_GSO_MASK | NETIF_F_HW_CSUM |
 			   NETIF_F_HW_VLAN_TX;
-- 
1.7.11.7
