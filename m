From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/8] mlxsw: Renaming local variable names for consistency
Date: Wed,  6 Jan 2016 11:11:54 +0100
Message-ID: <1452075116-5726-7-git-send-email-jiri@resnulli.us>
References: <1452075116-5726-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:34519 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356AbcAFKMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 05:12:06 -0500
Received: by mail-wm0-f41.google.com with SMTP id u188so54432789wmu.1
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 02:12:06 -0800 (PST)
In-Reply-To: <1452075116-5726-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index dcf77c9..ad1bf7f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -545,15 +545,15 @@ static int mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 				   const struct switchdev_obj_port_vlan *vlan,
 				   struct switchdev_trans *trans)
 {
-	bool untagged_flag = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
-	bool pvid_flag = vlan->flags & BRIDGE_VLAN_INFO_PVID;
+	bool flag_untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
+	bool flag_pvid = vlan->flags & BRIDGE_VLAN_INFO_PVID;
 
 	if (switchdev_trans_ph_prepare(trans))
 		return 0;
 
 	return __mlxsw_sp_port_vlans_add(mlxsw_sp_port,
 					 vlan->vid_begin, vlan->vid_end,
-					 untagged_flag, pvid_flag);
+					 flag_untagged, flag_pvid);
 }
 
 static enum mlxsw_reg_sfd_rec_policy mlxsw_sp_sfd_rec_policy(bool dynamic)
-- 
1.9.3
