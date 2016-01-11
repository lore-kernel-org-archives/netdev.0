From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v5 06/10] netdev: add netdevice notifier type to trigger a reprogramming of offloads
Date: Mon, 11 Jan 2016 13:17:27 +0100
Message-ID: <1452514651-15445-7-git-send-email-hannes@stressinduktion.org>
References: <1452514651-15445-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:43732 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759387AbcAKMRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 07:17:45 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 312DC20B6B
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 07:17:45 -0500 (EST)
In-Reply-To: <1452514651-15445-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/netdevice.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2285596e704589..0d4ee1315cb08a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2185,6 +2185,7 @@ struct netdev_lag_lower_state_info {
 #define NETDEV_BONDING_INFO	0x0019
 #define NETDEV_PRECHANGEUPPER	0x001A
 #define NETDEV_CHANGELOWERSTATE	0x001B
+#define NETDEV_REFRESH_OFFLOADS	0x001C
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
-- 
2.5.0
