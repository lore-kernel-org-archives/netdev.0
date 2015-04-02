From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 13/16] net/mlx5_core: Update module info macros for ConnectX4 Support
Date: Thu,  2 Apr 2015 17:07:31 +0300
Message-ID: <1427983654-971-14-git-send-email-eli@mellanox.com>
References: <1427983654-971-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, idos@mellaox.com, amirv@mellanox.com,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:35819 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075AbbDBOIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:08:12 -0400
Received: by widdi4 with SMTP id di4so80051124wid.0
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 07:08:11 -0700 (PDT)
In-Reply-To: <1427983654-971-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Declare the support of new ConnectX4 HCA in module info
Pump up the module version

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 78dfdab1ead4..fe41a7c2c629 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -48,11 +48,11 @@
 #include "mlx5_core.h"
 
 #define DRIVER_NAME "mlx5_core"
-#define DRIVER_VERSION "2.2-1"
-#define DRIVER_RELDATE	"Feb 2014"
+#define DRIVER_VERSION "3.0"
+#define DRIVER_RELDATE  "January 2015"
 
 MODULE_AUTHOR("Eli Cohen <eli@mellanox.com>");
-MODULE_DESCRIPTION("Mellanox ConnectX-IB HCA core library");
+MODULE_DESCRIPTION("Mellanox Connect-IB, ConnectX-4 core driver");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_VERSION(DRIVER_VERSION);
 
-- 
2.3.1
