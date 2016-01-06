From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v3 6/8] netdev: add netdevice notifier type to trigger a reprogramming of offloads
Date: Thu,  7 Jan 2016 00:39:29 +0100
Message-ID: <1452123571-19140-7-git-send-email-hannes@stressinduktion.org>
References: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:42310 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752519AbcAFXjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 18:39:49 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 111CB206E6
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 18:39:49 -0500 (EST)
In-Reply-To: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/netdevice.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8d8e5ca951b493..9750e46760695d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2183,6 +2183,7 @@ struct netdev_lag_lower_state_info {
 #define NETDEV_BONDING_INFO	0x0019
 #define NETDEV_PRECHANGEUPPER	0x001A
 #define NETDEV_CHANGELOWERSTATE	0x001B
+#define NETDEV_REFRESH_OFFLOADS	0x001C
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
-- 
2.5.0
