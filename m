From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 3/3] mlxsw: spectrum: Fix ordering in mlxsw_sp_fini
Date: Fri,  6 May 2016 11:17:24 +0200
Message-ID: <1462526244-11898-4-git-send-email-jiri@resnulli.us>
References: <1462526244-11898-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36952 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758122AbcEFJRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 05:17:30 -0400
Received: by mail-wm0-f41.google.com with SMTP id a17so67537366wme.0
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 02:17:30 -0700 (PDT)
In-Reply-To: <1462526244-11898-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Fixes: 0f433fa0ec ("mlxsw: spectrum_buffers: Implement shared buffer configuration")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 668b2f4..749cc27 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2159,6 +2159,7 @@ static void mlxsw_sp_fini(void *priv)
 	struct mlxsw_sp *mlxsw_sp = priv;
 
 	mlxsw_sp_switchdev_fini(mlxsw_sp);
+	mlxsw_sp_buffers_fini(mlxsw_sp);
 	mlxsw_sp_traps_fini(mlxsw_sp);
 	mlxsw_sp_event_unregister(mlxsw_sp, MLXSW_TRAP_ID_PUDE);
 	mlxsw_sp_ports_remove(mlxsw_sp);
-- 
2.5.5
