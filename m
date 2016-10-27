From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 03/10] net/mlx4_core: Change the default value of enable_qos
Date: Thu, 27 Oct 2016 16:27:15 +0300
Message-ID: <1477574842-29688-4-git-send-email-tariqt@mellanox.com>
References: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Moshe Lazer <moshel@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57521 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S941402AbcJ0NyR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 09:54:17 -0400
In-Reply-To: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Lazer <moshel@mellanox.com>

Change the default status of quality of service back to disabled,
as it hurts performance in some cases.

Fixes: 38438f7c7e8c ("net/mlx4: Set enhanced QoS support by default when ...")
Signed-off-by: Moshe Lazer <moshel@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index c41ab31a39f8..84bab9f0732e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -49,9 +49,9 @@ enum {
 extern void __buggy_use_of_MLX4_GET(void);
 extern void __buggy_use_of_MLX4_PUT(void);
 
-static bool enable_qos = true;
+static bool enable_qos;
 module_param(enable_qos, bool, 0444);
-MODULE_PARM_DESC(enable_qos, "Enable Enhanced QoS support (default: on)");
+MODULE_PARM_DESC(enable_qos, "Enable Enhanced QoS support (default: off)");
 
 #define MLX4_GET(dest, source, offset)				      \
 	do {							      \
-- 
1.8.3.1
