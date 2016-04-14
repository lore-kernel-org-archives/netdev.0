From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/18] mlxsw: core: Add mlxsw_core_port_driver_priv helper
Date: Thu, 14 Apr 2016 18:19:23 +0200
Message-ID: <1460650770-19382-12-git-send-email-jiri@resnulli.us>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36989 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964810AbcDNQTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 12:19:48 -0400
Received: by mail-wm0-f43.google.com with SMTP id n3so133913695wmn.0
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 09:19:48 -0700 (PDT)
In-Reply-To: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Needed in following patch.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 184e985..d0c471f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -137,6 +137,15 @@ struct mlxsw_core_port {
 	struct devlink_port devlink_port;
 };
 
+static inline void *
+mlxsw_core_port_driver_priv(struct mlxsw_core_port *mlxsw_core_port)
+{
+	/* mlxsw_core_port is ensured to always be the first field in driver
+	 * port structure.
+	 */
+	return mlxsw_core_port;
+}
+
 int mlxsw_core_port_init(struct mlxsw_core *mlxsw_core,
 			 struct mlxsw_core_port *mlxsw_core_port, u8 local_port,
 			 struct net_device *dev, bool split, u32 split_group);
-- 
2.5.5
