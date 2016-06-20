From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/23] mlxsw: spectrum: Use DECLARE_BITMAP() macro
Date: Mon, 20 Jun 2016 23:04:07 +0200
Message-ID: <1466456661-5260-10-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:32877 "EHLO
	mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933076AbcFTVTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:19:32 -0400
Received: by mail-lf0-f67.google.com with SMTP id l188so6853223lfe.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:19:31 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

There is a macro to do this kind of declarations, so use it.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 13b30ea..5da98b4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -155,17 +155,17 @@ struct mlxsw_sp_sb {
 struct mlxsw_sp {
 	struct {
 		struct list_head list;
-		unsigned long mapped[BITS_TO_LONGS(MLXSW_SP_VFID_PORT_MAX)];
+		DECLARE_BITMAP(mapped, MLXSW_SP_VFID_PORT_MAX);
 	} port_vfids;
 	struct {
 		struct list_head list;
-		unsigned long mapped[BITS_TO_LONGS(MLXSW_SP_VFID_BR_MAX)];
+		DECLARE_BITMAP(mapped, MLXSW_SP_VFID_BR_MAX);
 	} br_vfids;
 	struct {
 		struct list_head list;
-		unsigned long mapped[BITS_TO_LONGS(MLXSW_SP_MID_MAX)];
+		DECLARE_BITMAP(mapped, MLXSW_SP_MID_MAX);
 	} br_mids;
-	unsigned long active_fids[BITS_TO_LONGS(VLAN_N_VID)];
+	DECLARE_BITMAP(active_fids, VLAN_N_VID);
 	struct mlxsw_sp_port **ports;
 	struct mlxsw_core *core;
 	const struct mlxsw_bus_info *bus_info;
-- 
2.5.5
