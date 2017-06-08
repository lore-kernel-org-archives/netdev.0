From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 08/19] mlxsw: spectrum_switchdev: Add support for querying supported bridge flags
Date: Thu,  8 Jun 2017 08:44:17 +0200
Message-ID: <20170608064428.4785-9-jiri@resnulli.us>
References: <20170608064428.4785-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com,
        nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35390 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751516AbdFHGom (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 02:44:42 -0400
Received: by mail-wm0-f66.google.com with SMTP id g15so5661146wmc.2
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 23:44:42 -0700 (PDT)
In-Reply-To: <20170608064428.4785-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for querying supported bridge flags.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index eb88b72..0333493 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -456,6 +456,9 @@ static int mlxsw_sp_port_attr_get(struct net_device *dev,
 		mlxsw_sp_port_bridge_flags_get(mlxsw_sp->bridge, attr->orig_dev,
 					       &attr->u.brport_flags);
 		break;
+	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS_SUPPORT:
+		attr->u.brport_flags_support = BR_LEARNING | BR_FLOOD;
+		break;
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
2.9.3
