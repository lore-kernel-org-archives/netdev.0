From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/7] ixgbe: bump version number
Date: Wed, 28 Nov 2012 05:06:18 -0800
Message-ID: <1354107978-24731-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1354107978-24731-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44979 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932097Ab2K1NG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 08:06:27 -0500
In-Reply-To: <1354107978-24731-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Move the version string to better reflect the driver functionality with
that of the out of tree driver.  Also since we no longer need the MAJ,
MIN, BUILD defines remove them to clean up the code.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index fee0f8c..484bbed 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -63,11 +63,7 @@ char ixgbe_default_device_descr[] =
 static char ixgbe_default_device_descr[] =
 			      "Intel(R) 10 Gigabit Network Connection";
 #endif
-#define MAJ 3
-#define MIN 9
-#define BUILD 15
-#define DRV_VERSION __stringify(MAJ) "." __stringify(MIN) "." \
-	__stringify(BUILD) "-k"
+#define DRV_VERSION "3.11.33-k"
 const char ixgbe_driver_version[] = DRV_VERSION;
 static const char ixgbe_copyright[] =
 				"Copyright (c) 1999-2012 Intel Corporation.";
-- 
1.7.11.7
