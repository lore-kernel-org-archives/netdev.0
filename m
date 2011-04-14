From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 14/24] ixgbe: update version string for Dell CEM use
Date: Wed, 13 Apr 2011 18:02:10 -0700
Message-ID: <1302742940-22141-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:65381 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758149Ab1DNBCf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:35 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 6f8adc7..3dbe689 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -51,8 +51,12 @@
 char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
 			      "Intel(R) 10 Gigabit PCI Express Network Driver";
-
-#define DRV_VERSION "3.2.9-k2"
+#define MAJ 3
+#define MIN 2
+#define BUILD 9
+#define KFIX 2
+#define DRV_VERSION __stringify(MAJ) "." __stringify(MIN) "." \
+	__stringify(BUILD) "-k" __stringify(KFIX)
 const char ixgbe_driver_version[] = DRV_VERSION;
 static const char ixgbe_copyright[] =
 				"Copyright (c) 1999-2011 Intel Corporation.";
-- 
1.7.4.2

