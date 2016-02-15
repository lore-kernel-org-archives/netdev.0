From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] mlxsw: Treat local port 64 as valid
Date: Mon, 15 Feb 2016 13:19:53 +0100
Message-ID: <1455538794-2823-2-git-send-email-jiri@resnulli.us>
References: <1455538794-2823-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:34360 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753040AbcBOMT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 07:19:58 -0500
Received: by mail-wm0-f53.google.com with SMTP id b205so65173407wmb.1
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 04:19:57 -0800 (PST)
In-Reply-To: <1455538794-2823-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

MLXSW_PORT_MAX_PORTS represents the maximum number of local ports, which
is 65 for both ASICs (SwitchX-2 and Spectrum) supported by this driver.

Fixes: 93c1edb27f9e ("mlxsw: Introduce Mellanox switch driver core")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/port.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/port.h b/drivers/net/ethernet/mellanox/mlxsw/port.h
index 726f543..ae65b99 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/port.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/port.h
@@ -49,7 +49,7 @@
 #define MLXSW_PORT_MID			0xd000
 
 #define MLXSW_PORT_MAX_PHY_PORTS	0x40
-#define MLXSW_PORT_MAX_PORTS		MLXSW_PORT_MAX_PHY_PORTS
+#define MLXSW_PORT_MAX_PORTS		(MLXSW_PORT_MAX_PHY_PORTS + 1)
 
 #define MLXSW_PORT_DEVID_BITS_OFFSET	10
 #define MLXSW_PORT_PHY_BITS_OFFSET	4
-- 
1.9.3
