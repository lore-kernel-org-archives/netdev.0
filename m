From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/21] mlxsw: spectrum_router: Publish mlxsw_sp_l3proto
Date: Sat,  2 Sep 2017 17:21:12 +0200
Message-ID: <20170902152126.17286-8-jiri@resnulli.us>
References: <20170902152126.17286-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36486 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752741AbdIBPVl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 11:21:41 -0400
Received: by mail-wr0-f193.google.com with SMTP id 40so1350099wrv.3
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 08:21:40 -0700 (PDT)
In-Reply-To: <20170902152126.17286-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

The spectrum_ipip module that will be introduced in the follow-up
patches needs to know the data type.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 5 -----
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h | 5 +++++
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 4e47d45..f866ac5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -405,11 +405,6 @@ struct mlxsw_sp_rt6 {
 	struct rt6_info *rt;
 };
 
-enum mlxsw_sp_l3proto {
-	MLXSW_SP_L3_PROTO_IPV4,
-	MLXSW_SP_L3_PROTO_IPV6,
-};
-
 struct mlxsw_sp_lpm_tree {
 	u8 id; /* tree ID */
 	unsigned int ref_count;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
index 87a04af..67c6c1d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
@@ -37,6 +37,11 @@
 
 #include "spectrum.h"
 
+enum mlxsw_sp_l3proto {
+	MLXSW_SP_L3_PROTO_IPV4,
+	MLXSW_SP_L3_PROTO_IPV6,
+};
+
 enum mlxsw_sp_rif_counter_dir {
 	MLXSW_SP_RIF_COUNTER_INGRESS,
 	MLXSW_SP_RIF_COUNTER_EGRESS,
-- 
2.9.3
