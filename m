From: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Subject: [PATCH] IB/mlx5_core: remove unreachable function call in module init
Date: Fri,  7 Mar 2014 19:48:25 -0300
Message-ID: <1394232505-12142-1-git-send-email-klebers@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
To: Eli Cohen <eli@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:48081 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753551AbaCGWsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 17:48:51 -0500
Received: from /spool/local
	by e24smtp02.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <klebers@linux.vnet.ibm.com>;
	Fri, 7 Mar 2014 19:48:46 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The call to mlx5_health_cleanup() in the module init function can never
be reached. Removing it.

Signed-off-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 6f7c866..77ac95f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -531,7 +531,6 @@ static int __init init(void)
 
 	return 0;
 
-	mlx5_health_cleanup();
 err_debug:
 	mlx5_unregister_debugfs();
 	return err;
-- 
1.7.1
