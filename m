From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/26] net: add netif_is_team_port helper
Date: Tue,  1 Dec 2015 14:48:41 +0100
Message-ID: <1448977744-17930-4-git-send-email-jiri@resnulli.us>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35125 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755220AbbLANtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:49:12 -0500
Received: by wmuu63 with SMTP id u63so173624486wmu.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 05:49:11 -0800 (PST)
In-Reply-To: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Similar to other helpers, caller can use this to find out if device is
team port.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cfb56e0..e7eca8f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3895,6 +3895,11 @@ static inline bool netif_is_team_master(struct net_device *dev)
 	return dev->priv_flags & IFF_TEAM;
 }
 
+static inline bool netif_is_team_port(struct net_device *dev)
+{
+	return dev->priv_flags & IFF_TEAM_PORT;
+}
+
 /* This device needs to keep skb dst for qdisc enqueue or ndo_start_xmit() */
 static inline void netif_keep_dst(struct net_device *dev)
 {
-- 
1.9.3
