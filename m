From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/8] net: add netif_is_ovs_port helper
Date: Tue, 18 Apr 2017 16:55:36 +0200
Message-ID: <1492527338-13298-7-git-send-email-jiri@resnulli.us>
References: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33306 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755244AbdDROzt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 10:55:49 -0400
Received: by mail-wm0-f65.google.com with SMTP id o81so15233988wmb.0
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 07:55:48 -0700 (PDT)
In-Reply-To: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

To find out if a netdev is an OVS port.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 include/linux/netdevice.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b0aa089..0f3c38c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4171,6 +4171,11 @@ static inline bool netif_is_ovs_master(const struct net_device *dev)
 	return dev->priv_flags & IFF_OPENVSWITCH;
 }
 
+static inline bool netif_is_ovs_port(const struct net_device *dev)
+{
+	return dev->priv_flags & IFF_OVS_DATAPATH;
+}
+
 static inline bool netif_is_team_master(const struct net_device *dev)
 {
 	return dev->priv_flags & IFF_TEAM;
-- 
2.7.4
