From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/6] e1000e: minor re-order of #include files
Date: Thu,  4 Aug 2011 05:18:15 -0700
Message-ID: <1312460298-20405-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312460298-20405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:1910 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449Ab1HDMSk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2011 08:18:40 -0400
In-Reply-To: <1312460298-20405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The recent commit a6b7a407 when back-ported to the out-of-tree e1000e
driver caused a compilation error on older kernels which required a
re-ordering of the #include files.  This cosmetic patch syncs the two
drivers for easier maintainability.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ethtool.c |    2 +-
 drivers/net/e1000e/netdev.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 72756e4..06d88f3 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -28,8 +28,8 @@
 
 /* ethtool support for e1000 */
 
-#include <linux/interrupt.h>
 #include <linux/netdevice.h>
+#include <linux/interrupt.h>
 #include <linux/ethtool.h>
 #include <linux/pci.h>
 #include <linux/slab.h>
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 4353ad5..ab4be80 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -31,12 +31,12 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/init.h>
-#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/vmalloc.h>
 #include <linux/pagemap.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
+#include <linux/interrupt.h>
 #include <linux/tcp.h>
 #include <linux/ipv6.h>
 #include <linux/slab.h>
-- 
1.7.6

