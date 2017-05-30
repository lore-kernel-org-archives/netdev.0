From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 2/3] MAINTAINERS: Move mlx4 rdma header file to IB driver charge
Date: Tue, 30 May 2017 11:44:05 +0300
Message-ID: <1496133846-18343-3-git-send-email-tariqt@mellanox.com>
References: <1496133846-18343-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Majd Dibbiny <majd@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Yishai Hadas <yishaih@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41288 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750911AbdE3Iop (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 04:44:45 -0400
In-Reply-To: <1496133846-18343-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It belongs there, should not be under mlx4 Core driver.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 MAINTAINERS | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index d9d5398d0a49..0dbc20c963c4 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8516,7 +8516,6 @@ Q:	http://patchwork.ozlabs.org/project/netdev/list/
 S:	Supported
 F:	drivers/net/ethernet/mellanox/mlx4/
 F:	include/linux/mlx4/
-F:	include/uapi/rdma/mlx4-abi.h
 
 MELLANOX MLX4 IB driver
 M:	Yishai Hadas <yishaih@mellanox.com>
@@ -8526,6 +8525,7 @@ Q:	http://patchwork.kernel.org/project/linux-rdma/list/
 S:	Supported
 F:	drivers/infiniband/hw/mlx4/
 F:	include/linux/mlx4/
+F:	include/uapi/rdma/mlx4-abi.h
 
 MELLANOX MLX5 core VPI driver
 M:	Saeed Mahameed <saeedm@mellanox.com>
-- 
1.8.3.1
