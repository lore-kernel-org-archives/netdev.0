From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] spider_net: fix compile issue introduced by driver
 move
Date: Thu, 11 Aug 2011 23:05:52 -0700 (PDT)
Message-ID: <20110811.230552.837691497153518712.davem@davemloft.net>
References: <20110812144131.59de312ee6e1a9e8865c1a85@canb.auug.org.au>
	<20110812150003.1e2ba71018bea040fc7649d7@canb.auug.org.au>
	<20110811.230017.1431877798231142541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110811.230017.1431877798231142541.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 11 Aug 2011 23:00:17 -0700 (PDT)

> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Fri, 12 Aug 2011 15:00:03 +1000
> 
>> However, Dave, I now get these (powerpc ppc64defconfig build of just the
>> net tree):
> 
> This should fix the cxgbi scsi problems, I'll work on the mlx4 ones
> next.

And this one will fix the mlx4 infiniband problems, thanks Stephen.

--------------------
>From af3dcd2f449b7243a4c7b987125ffc40fad262f0 Mon Sep 17 00:00:00 2001
From: "David S. Miller" <davem@davemloft.net>
Date: Thu, 11 Aug 2011 23:05:05 -0700
Subject: [PATCH] mlx4: Fix infiniband Kconfig dependencies.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/hw/mlx4/Kconfig |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/Kconfig b/drivers/infiniband/hw/mlx4/Kconfig
index bd995b2..24ab11a 100644
--- a/drivers/infiniband/hw/mlx4/Kconfig
+++ b/drivers/infiniband/hw/mlx4/Kconfig
@@ -1,6 +1,7 @@
 config MLX4_INFINIBAND
 	tristate "Mellanox ConnectX HCA support"
-	depends on NETDEVICES && NETDEV_10000 && PCI
+	depends on NETDEVICES && ETHERNET && PCI
+	select NET_VENDOR_MELLANOX
 	select MLX4_CORE
 	---help---
 	  This driver provides low-level InfiniBand support for
-- 
1.7.6
