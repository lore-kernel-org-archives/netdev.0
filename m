From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next] mlxsw: spectrum: Make offloads stats functions static
Date: Tue, 20 Sep 2016 08:14:08 +0300
Message-ID: <1474348448-13724-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>,
        Nogah Frankel <nogahf@mellanox.com>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42959 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751040AbcITFOV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 01:14:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The offloads stats functions are local to this file, make them static.

Fixes: fc1bbb0f1831 ('mlxsw: spectrum: Implement offload stats ndo [..]')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 171f8dd..efac909 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -819,7 +819,7 @@ err_span_port_mtu_update:
 	return err;
 }
 
-int
+static int
 mlxsw_sp_port_get_sw_stats64(const struct net_device *dev,
 			     struct rtnl_link_stats64 *stats)
 {
@@ -851,7 +851,7 @@ mlxsw_sp_port_get_sw_stats64(const struct net_device *dev,
 	return 0;
 }
 
-bool mlxsw_sp_port_has_offload_stats(int attr_id)
+static bool mlxsw_sp_port_has_offload_stats(int attr_id)
 {
 	switch (attr_id) {
 	case IFLA_OFFLOAD_XSTATS_CPU_HIT:
@@ -861,8 +861,8 @@ bool mlxsw_sp_port_has_offload_stats(int attr_id)
 	return false;
 }
 
-int mlxsw_sp_port_get_offload_stats(int attr_id, const struct net_device *dev,
-				    void *sp)
+static int mlxsw_sp_port_get_offload_stats(int attr_id, const struct net_device *dev,
+					   void *sp)
 {
 	switch (attr_id) {
 	case IFLA_OFFLOAD_XSTATS_CPU_HIT:
-- 
2.3.7
