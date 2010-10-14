From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] infiniband: fix mlx4 kconfig dependency warning
Date: Wed, 13 Oct 2010 18:12:53 -0700
Message-ID: <20101013181253.f3f5cd6f.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, Roland Dreier <rolandd@cisco.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>
To: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, akpm <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix kconfig dependency warning to satisfy dependencies:

warning: (MLX4_EN && NETDEVICES && NETDEV_10000 && PCI && INET || MLX4_INFINIBAND && INFINIBAND) selects MLX4_CORE which has unmet direct dependencies (NETDEVICES && NETDEV_10000 && PCI)

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/infiniband/hw/mlx4/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- linux-next-20101013.orig/drivers/infiniband/hw/mlx4/Kconfig
+++ linux-next-20101013/drivers/infiniband/hw/mlx4/Kconfig
@@ -1,5 +1,6 @@
 config MLX4_INFINIBAND
 	tristate "Mellanox ConnectX HCA support"
+	depends on NETDEVICES && NETDEV_10000 && PCI
 	select MLX4_CORE
 	---help---
 	  This driver provides low-level InfiniBand support for
