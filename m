From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/4] mlxsw: spectrum: Initialize PVID only once
Date: Mon,  4 Jan 2016 10:42:23 +0100
Message-ID: <1451900546-2006-2-git-send-email-jiri@resnulli.us>
References: <1451900546-2006-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35270 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481AbcADJma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 04:42:30 -0500
Received: by mail-wm0-f44.google.com with SMTP id f206so133499418wmf.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 01:42:30 -0800 (PST)
In-Reply-To: <1451900546-2006-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We set PVID to 1 in mlxsw_sp_port_vlan_init(), so we can remove this
statement.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index c588c65..6cc1125 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1367,7 +1367,6 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	mlxsw_sp_port->learning = 1;
 	mlxsw_sp_port->learning_sync = 1;
 	mlxsw_sp_port->uc_flood = 1;
-	mlxsw_sp_port->pvid = 1;
 	bytes = DIV_ROUND_UP(VLAN_N_VID, BITS_PER_BYTE);
 	mlxsw_sp_port->active_vlans = kzalloc(bytes, GFP_KERNEL);
 	if (!mlxsw_sp_port->active_vlans) {
-- 
1.9.3
