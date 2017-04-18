From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/8] mlxsw: spectrum: Fix indent in mlxsw_sp_netdevice_port_upper_event
Date: Tue, 18 Apr 2017 16:55:31 +0200
Message-ID: <1492527338-13298-2-git-send-email-jiri@resnulli.us>
References: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33226 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754395AbdDROzm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 10:55:42 -0400
Received: by mail-wm0-f66.google.com with SMTP id o81so15233374wmb.0
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 07:55:42 -0700 (PDT)
In-Reply-To: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index b031f09..9b9861a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4038,8 +4038,8 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 				err = mlxsw_sp_port_vlan_link(mlxsw_sp_port,
 							      upper_dev);
 			else
-				 mlxsw_sp_port_vlan_unlink(mlxsw_sp_port,
-							   upper_dev);
+				mlxsw_sp_port_vlan_unlink(mlxsw_sp_port,
+							  upper_dev);
 		} else if (netif_is_bridge_master(upper_dev)) {
 			if (info->linking)
 				err = mlxsw_sp_port_bridge_join(mlxsw_sp_port,
-- 
2.7.4
