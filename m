From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/8] mlxsw: reg.h: Namespace IP2ME registers
Date: Mon, 31 Jul 2017 09:27:27 +0200
Message-ID: <20170731072730.3256-6-jiri@resnulli.us>
References: <20170731072730.3256-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:38025 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751740AbdGaH1l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 03:27:41 -0400
Received: by mail-wm0-f68.google.com with SMTP id y206so11408313wmd.5
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 00:27:40 -0700 (PDT)
In-Reply-To: <20170731072730.3256-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

This renames IP2ME-specific registers reg_ralue_v and
reg_ralue_tunnel_ptr to reg_ralue_ip2me_*.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index a671438..7e8ba54 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4813,7 +4813,7 @@ MLXSW_ITEM32(reg, ralue, ecmp_size, 0x28, 0, 13);
  */
 MLXSW_ITEM32(reg, ralue, local_erif, 0x24, 0, 16);
 
-/* reg_ralue_v
+/* reg_ralue_ip2me_v
  * Valid bit for the tunnel_ptr field.
  * If valid = 0 then trap to CPU as IP2ME trap ID.
  * If valid = 1 and the packet format allows NVE or IPinIP tunnel
@@ -4823,15 +4823,15 @@ MLXSW_ITEM32(reg, ralue, local_erif, 0x24, 0, 16);
  * Only relevant in case of IP2ME action.
  * Access: RW
  */
-MLXSW_ITEM32(reg, ralue, v, 0x24, 31, 1);
+MLXSW_ITEM32(reg, ralue, ip2me_v, 0x24, 31, 1);
 
-/* reg_ralue_tunnel_ptr
+/* reg_ralue_ip2me_tunnel_ptr
  * Tunnel Pointer for NVE or IPinIP tunnel decapsulation.
  * For Spectrum, pointer to KVD Linear.
  * Only relevant in case of IP2ME action.
  * Access: RW
  */
-MLXSW_ITEM32(reg, ralue, tunnel_ptr, 0x24, 0, 24);
+MLXSW_ITEM32(reg, ralue, ip2me_tunnel_ptr, 0x24, 0, 24);
 
 static inline void mlxsw_reg_ralue_pack(char *payload,
 					enum mlxsw_reg_ralxx_protocol protocol,
-- 
2.9.3
