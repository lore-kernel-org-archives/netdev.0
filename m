From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH] net, mc: fix the incorrect comments in two mc-related functions
Date: Mon, 28 Oct 2013 16:15:50 +0800
Message-ID: <1382948150-14349-1-git-send-email-zwu.kernel@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 net/core/dev_addr_lists.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index 6cda4e2..ec40a84 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -752,7 +752,7 @@ int dev_mc_del_global(struct net_device *dev, const unsigned char *addr)
 EXPORT_SYMBOL(dev_mc_del_global);
 
 /**
- *	dev_mc_sync - Synchronize device's unicast list to another device
+ *	dev_mc_sync - Synchronize device's multicast list to another device
  *	@to: destination device
  *	@from: source device
  *
@@ -780,7 +780,7 @@ int dev_mc_sync(struct net_device *to, struct net_device *from)
 EXPORT_SYMBOL(dev_mc_sync);
 
 /**
- *	dev_mc_sync_multiple - Synchronize device's unicast list to another
+ *	dev_mc_sync_multiple - Synchronize device's multicast list to another
  *	device, but allow for multiple calls to sync to multiple devices.
  *	@to: destination device
  *	@from: source device
-- 
1.7.11.7
