From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/4] net: Add ndo_fcoe_get_wwn to net_device_ops
Date: Wed, 28 Oct 2009 21:24:35 -0700
Message-ID: <20091029042434.15957.82934.stgit@localhost.localdomain>
References: <20091029042339.15957.37676.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	linux-scsi@vger.kernel.org, Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20091029042339.15957.37676.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yi Zou <yi.zou@intel.com>

Add ndo_fcoe_get_wwn so Fiber Channel over Ethernet (FCoE) can make use of
the provided World Wide Port Name (WWPN) and World Wide Node Name (WWNN)
from the underlying network interface driver.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/netdevice.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e7c227d..656110a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -635,6 +635,10 @@ struct net_device_ops {
 						      unsigned int sgc);
 	int			(*ndo_fcoe_ddp_done)(struct net_device *dev,
 						     u16 xid);
+#define NETDEV_FCOE_WWNN 0
+#define NETDEV_FCOE_WWPN 1
+	int			(*ndo_fcoe_get_wwn)(struct net_device *dev,
+						    u64 *wwn, int type);
 #endif
 };
 

