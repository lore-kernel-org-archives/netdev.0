From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 18/26] mlxsw: spectrum: Add set_rx_mode ndo stub
Date: Tue,  1 Dec 2015 14:48:56 +0100
Message-ID: <1448977744-17930-19-git-send-email-jiri@resnulli.us>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35462 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755648AbbLANtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:49:31 -0500
Received: by wmuu63 with SMTP id u63so173636549wmu.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 05:49:30 -0800 (PST)
In-Reply-To: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add just a stub for now. This allows to pass check in dev_ifsioc,
SIOCADDMULTI and SIOCDELMULTI cases. Teamd is using these to add LACP
slow MAC.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 14a9a9f..a397cc1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -417,6 +417,10 @@ static netdev_tx_t mlxsw_sp_port_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
+static void mlxsw_sp_set_rx_mode(struct net_device *dev)
+{
+}
+
 static int mlxsw_sp_port_set_mac_address(struct net_device *dev, void *p)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
@@ -725,6 +729,7 @@ static const struct net_device_ops mlxsw_sp_port_netdev_ops = {
 	.ndo_open		= mlxsw_sp_port_open,
 	.ndo_stop		= mlxsw_sp_port_stop,
 	.ndo_start_xmit		= mlxsw_sp_port_xmit,
+	.ndo_set_rx_mode	= mlxsw_sp_set_rx_mode,
 	.ndo_set_mac_address	= mlxsw_sp_port_set_mac_address,
 	.ndo_change_mtu		= mlxsw_sp_port_change_mtu,
 	.ndo_get_stats64	= mlxsw_sp_port_get_stats64,
-- 
1.9.3
