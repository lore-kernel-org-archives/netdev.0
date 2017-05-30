From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 3/3] MAINTAINERS: Move mlx5 rdma header file to IB driver charge
Date: Tue, 30 May 2017 11:44:06 +0300
Message-ID: <1496133846-18343-4-git-send-email-tariqt@mellanox.com>
References: <1496133846-18343-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Majd Dibbiny <majd@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Yishai Hadas <yishaih@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41287 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750985AbdE3Iop (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 04:44:45 -0400
In-Reply-To: <1496133846-18343-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It belongs there, should not be under mlx5 Core driver.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 MAINTAINERS | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 0dbc20c963c4..0f92a2ff4b12 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8538,7 +8538,6 @@ Q:	http://patchwork.ozlabs.org/project/netdev/list/
 S:	Supported
 F:	drivers/net/ethernet/mellanox/mlx5/core/
 F:	include/linux/mlx5/
-F:	include/uapi/rdma/mlx5-abi.h
 
 MELLANOX MLX5 IB driver
 M:	Matan Barak <matanb@mellanox.com>
@@ -8549,6 +8548,7 @@ Q:	http://patchwork.kernel.org/project/linux-rdma/list/
 S:	Supported
 F:	drivers/infiniband/hw/mlx5/
 F:	include/linux/mlx5/
+F:	include/uapi/rdma/mlx5-abi.h
 
 MELEXIS MLX90614 DRIVER
 M:	Crt Mori <cmo@melexis.com>
-- 
1.8.3.1
