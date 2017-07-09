From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 6/7] net/mlx5: Add Makefiles for subdirectories
Date: Sun,  9 Jul 2017 15:49:16 +0300
Message-ID: <20170709124917.12852-7-saeedm@mellanox.com>
References: <20170709124917.12852-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Ilan Tayari <ilant@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36242 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752148AbdGIMuH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2017 08:50:07 -0400
In-Reply-To: <20170709124917.12852-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Currently it is not possible to build just one .o file inside
a subdirectory, because the subdirectories lack a Makefile.

Add a Makefile to the mlx5 subdirectories.

Fixes: e29341fb3a5b ("net/mlx5: FPGA, Add basic support for Innova")
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Reported-by: David Miller <davem@davemloft.net>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/accel/Makefile    | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_accel/Makefile | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/fpga/Makefile     | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/Makefile    | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/lib/Makefile      | 1 +
 5 files changed, 5 insertions(+)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/accel/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_accel/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fpga/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/ipoib/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/lib/Makefile

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/accel/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/accel/Makefile
new file mode 100644
index 000000000000..d8e17110f25d
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/accel/Makefile
@@ -0,0 +1 @@
+subdir-ccflags-y += -I$(src)/..
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_accel/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/en_accel/Makefile
new file mode 100644
index 000000000000..d8e17110f25d
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_accel/Makefile
@@ -0,0 +1 @@
+subdir-ccflags-y += -I$(src)/..
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fpga/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/fpga/Makefile
new file mode 100644
index 000000000000..d8e17110f25d
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fpga/Makefile
@@ -0,0 +1 @@
+subdir-ccflags-y += -I$(src)/..
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/Makefile
new file mode 100644
index 000000000000..d8e17110f25d
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/Makefile
@@ -0,0 +1 @@
+subdir-ccflags-y += -I$(src)/..
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/lib/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/lib/Makefile
new file mode 100644
index 000000000000..d8e17110f25d
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/lib/Makefile
@@ -0,0 +1 @@
+subdir-ccflags-y += -I$(src)/..
-- 
2.11.0
