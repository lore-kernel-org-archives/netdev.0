From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/6] net: add netif_is_bridge_master helper
Date: Wed, 26 Aug 2015 18:36:34 +0200
Message-ID: <1440606998-11072-3-git-send-email-jiri@resnulli.us>
References: <1440606998-11072-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, simon.horman@netronome.com,
	Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36716 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473AbbHZQgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 12:36:43 -0400
Received: by wicja10 with SMTP id ja10so49990944wic.1
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 09:36:42 -0700 (PDT)
In-Reply-To: <1440606998-11072-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add this helper so code can easily figure out if netdev is a bridge.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 39f30da..be625f4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3848,6 +3848,11 @@ static inline bool netif_is_vrf(const struct net_device *dev)
 	return dev->priv_flags & IFF_VRF_MASTER;
 }
 
+static inline bool netif_is_bridge_master(const struct net_device *dev)
+{
+	return dev->priv_flags & IFF_EBRIDGE;
+}
+
 static inline bool netif_index_is_vrf(struct net *net, int ifindex)
 {
 	bool rc = false;
-- 
1.9.3
