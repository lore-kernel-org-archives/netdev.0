From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/10] mlxsw: spectrum_dpipe: Fix indentation in header description
Date: Mon, 25 Sep 2017 10:32:21 +0200
Message-ID: <20170925083230.1193-2-jiri@resnulli.us>
References: <20170925083230.1193-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35541 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932617AbdIYIcd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 04:32:33 -0400
Received: by mail-wr0-f193.google.com with SMTP id n64so1454491wrb.2
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 01:32:32 -0700 (PDT)
In-Reply-To: <20170925083230.1193-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Fix indentation in mlxsw_meta header's description.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 23 ++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index 51e6846..9164809 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -46,18 +46,21 @@ enum mlxsw_sp_field_metadata_id {
 };
 
 static struct devlink_dpipe_field mlxsw_sp_dpipe_fields_metadata[] = {
-	{ .name = "erif_port",
-	  .id = MLXSW_SP_DPIPE_FIELD_METADATA_ERIF_PORT,
-	  .bitwidth = 32,
-	  .mapping_type = DEVLINK_DPIPE_FIELD_MAPPING_TYPE_IFINDEX,
+	{
+		.name = "erif_port",
+		.id = MLXSW_SP_DPIPE_FIELD_METADATA_ERIF_PORT,
+		.bitwidth = 32,
+		.mapping_type = DEVLINK_DPIPE_FIELD_MAPPING_TYPE_IFINDEX,
 	},
-	{ .name = "l3_forward",
-	  .id = MLXSW_SP_DPIPE_FIELD_METADATA_L3_FORWARD,
-	  .bitwidth = 1,
+	{
+		.name = "l3_forward",
+		.id = MLXSW_SP_DPIPE_FIELD_METADATA_L3_FORWARD,
+		.bitwidth = 1,
 	},
-	{ .name = "l3_drop",
-	  .id = MLXSW_SP_DPIPE_FIELD_METADATA_L3_DROP,
-	  .bitwidth = 1,
+	{
+		.name = "l3_drop",
+		.id = MLXSW_SP_DPIPE_FIELD_METADATA_L3_DROP,
+		.bitwidth = 1,
 	},
 };
 
-- 
2.9.5
