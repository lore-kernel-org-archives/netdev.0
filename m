From: Joe Perches <joe@perches.com>
Subject: [PATCH 01/11] vmxnet3: Remove extern from function prototypes
Date: Wed, 25 Sep 2013 12:37:19 -0700
Message-ID: <d8dea1eb36bcc004416b9587f09730430905e5b7.1380137609.git.joe@perches.com>
References: <cover.1380137609.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380137609.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/vmxnet3/vmxnet3_int.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index a03f358..12040a3 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -410,9 +410,9 @@ int
 vmxnet3_create_queues(struct vmxnet3_adapter *adapter,
 		      u32 tx_ring_size, u32 rx_ring_size, u32 rx_ring2_size);
 
-extern void vmxnet3_set_ethtool_ops(struct net_device *netdev);
+void vmxnet3_set_ethtool_ops(struct net_device *netdev);
 
-extern struct rtnl_link_stats64 *
+struct rtnl_link_stats64 *
 vmxnet3_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats);
 
 extern char vmxnet3_driver_name[];
-- 
1.8.1.2.459.gbcd45b4.dirty
