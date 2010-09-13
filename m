From: Joe Perches <joe@perches.com>
Subject: [PATCH 14/25] drivers/net/vnxnet3: Use static const char arrays
Date: Mon, 13 Sep 2010 12:47:52 -0700
Message-ID: <a2e0d6f77c221ebf7f642dd02da85bcd41947242.1284406638.git.joe@perches.com>
References: <cover.1284406638.git.joe@perches.com>
Cc: Shreyas Bhatewara <sbhatewara@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1896 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755334Ab0IMTse (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Sep 2010 15:48:34 -0400
In-Reply-To: <cover.1284406638.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    2 +-
 drivers/net/vmxnet3/vmxnet3_int.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 198ce92..dfc0014 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -28,7 +28,7 @@
 
 #include "vmxnet3_int.h"
 
-char vmxnet3_driver_name[] = "vmxnet3";
+const char vmxnet3_driver_name[] = "vmxnet3";
 #define VMXNET3_DRIVER_DESC "VMware vmxnet3 virtual NIC driver"
 
 /*
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 2121c73..201fcf7 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -384,5 +384,5 @@ vmxnet3_create_queues(struct vmxnet3_adapter *adapter,
 extern void vmxnet3_set_ethtool_ops(struct net_device *netdev);
 extern struct net_device_stats *vmxnet3_get_stats(struct net_device *netdev);
 
-extern char vmxnet3_driver_name[];
+extern const char vmxnet3_driver_name[];
 #endif
-- 
1.7.3.rc1

