From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 25/33] net: infiniband - steal ifname label
Date: Thu, 10 Jul 2014 10:17:30 +0200
Message-ID: <1404980258-30853-26-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>,
	Tom Tucker <tom@opengridcomputing.com>,
	Steve Wise <swise@opengridcomputing.com>,
	Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	linux-rdma@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the same assign type, as the name we are basing our new name on.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Tom Tucker <tom@opengridcomputing.com>
Cc: Steve Wise <swise@opengridcomputing.com>
Cc: Roland Dreier <roland@kernel.org>
Cc: Sean Hefty <sean.hefty@intel.com>
Cc: Hal Rosenstock <hal.rosenstock@gmail.com>
Cc: linux-rdma@vger.kernel.org
---
 drivers/infiniband/hw/amso1100/c2_provider.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/amso1100/c2_provider.c b/drivers/infiniband/hw/amso1100/c2_provider.c
index 2d5cbf4..fc44460 100644
--- a/drivers/infiniband/hw/amso1100/c2_provider.c
+++ b/drivers/infiniband/hw/amso1100/c2_provider.c
@@ -734,7 +734,7 @@ static struct net_device *c2_pseudo_netdev_init(struct c2_dev *c2dev)
 	/* change ethxxx to iwxxx */
 	strcpy(name, "iw");
 	strcat(name, &c2dev->netdev->name[3]);
-	netdev = alloc_netdev(0, name, NET_NAME_UNKNOWN, setup);
+	netdev = alloc_netdev(0, name, c2dev->netdev->name_assign_type, setup);
 	if (!netdev) {
 		printk(KERN_ERR PFX "%s -  etherdev alloc failed",
 			__func__);
-- 
1.9.3
