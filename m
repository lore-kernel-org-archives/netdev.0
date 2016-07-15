From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/5] mlxsw: spectrum: Indicate support for autonegotiation
Date: Fri, 15 Jul 2016 11:14:59 +0200
Message-ID: <1468574102-26288-3-git-send-email-jiri@resnulli.us>
References: <1468574102-26288-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34324 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932472AbcGOJPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 05:15:08 -0400
Received: by mail-wm0-f66.google.com with SMTP id q128so1382480wma.1
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 02:15:07 -0700 (PDT)
In-Reply-To: <1468574102-26288-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The device supports link autonegotiation, so let the user know about it
by indicating support via ethtool ops.

Fixes: 56ade8fe3fe1 ("mlxsw: spectrum: Add initial support for Spectrum ASIC")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 5ccdf22..3740800 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1417,7 +1417,8 @@ static int mlxsw_sp_port_get_settings(struct net_device *dev,
 
 	cmd->supported = mlxsw_sp_from_ptys_supported_port(eth_proto_cap) |
 			 mlxsw_sp_from_ptys_supported_link(eth_proto_cap) |
-			 SUPPORTED_Pause | SUPPORTED_Asym_Pause;
+			 SUPPORTED_Pause | SUPPORTED_Asym_Pause |
+			 SUPPORTED_Autoneg;
 	cmd->advertising = mlxsw_sp_from_ptys_advert_link(eth_proto_admin);
 	mlxsw_sp_from_ptys_speed_duplex(netif_carrier_ok(dev),
 					eth_proto_oper, cmd);
-- 
2.5.5
