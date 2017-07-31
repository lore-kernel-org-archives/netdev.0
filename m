From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/8] mlxsw: reg.h: Fix a typo
Date: Mon, 31 Jul 2017 09:27:24 +0200
Message-ID: <20170731072730.3256-3-jiri@resnulli.us>
References: <20170731072730.3256-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34575 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751496AbdGaH1g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 03:27:36 -0400
Received: by mail-wr0-f195.google.com with SMTP id o33so23299513wrb.1
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 00:27:36 -0700 (PDT)
In-Reply-To: <20170731072730.3256-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index c6c50894..b4ea8cb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4718,7 +4718,7 @@ MLXSW_ITEM32(reg, ralue, prefix_len, 0x08, 0, 8);
 /* reg_ralue_dip*
  * The prefix of the route or of the marker that the object of the LPM
  * is compared with. The most significant bits of the dip are the prefix.
- * The list significant bits must be '0' if the prefix_len is smaller
+ * The least significant bits must be '0' if the prefix_len is smaller
  * than 128 for IPv6 or smaller than 32 for IPv4.
  * IPv4 address uses bits dip[31:0] and bits dip[127:32] are reserved.
  * Access: Index
-- 
2.9.3
