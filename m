From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] ixgbe: add cx4 device ID
Date: Fri, 08 Aug 2008 16:24:19 -0700
Message-ID: <20080808232419.17754.78857.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15338 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752821AbYHHXYX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 19:24:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This is a simple device ID add for adapters that support
CX4 (copper infiniband style cable) connectors for 10GbE.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c |    1 +
 drivers/net/ixgbe/ixgbe_main.c  |    4 +++-
 drivers/net/ixgbe/ixgbe_type.h  |    1 +
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 2f38e84..f96358b 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -190,6 +190,7 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_82598AF_DUAL_PORT:
 	case IXGBE_DEV_ID_82598AF_SINGLE_PORT:
 	case IXGBE_DEV_ID_82598EB_CX4:
+	case IXGBE_DEV_ID_82598_CX4_DUAL_PORT:
 		media_type = ixgbe_media_type_fiber;
 		break;
 	case IXGBE_DEV_ID_82598AT_DUAL_PORT:
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e5f3da8..34bca16 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -48,7 +48,7 @@ char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
 	"Intel(R) 10 Gigabit PCI Express Network Driver";
 
-#define DRV_VERSION "1.3.18-k2"
+#define DRV_VERSION "1.3.18-k4"
 const char ixgbe_driver_version[] = DRV_VERSION;
 static const char ixgbe_copyright[] =
 	 "Copyright (c) 1999-2007 Intel Corporation.";
@@ -72,6 +72,8 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598EB_CX4),
 	 board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598_CX4_DUAL_PORT),
+	 board_82598 },
 
 	/* required last entry */
 	{0, }
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 1ad7cb9..c0282a2 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -39,6 +39,7 @@
 #define IXGBE_DEV_ID_82598AF_SINGLE_PORT 0x10C7
 #define IXGBE_DEV_ID_82598AT_DUAL_PORT   0x10C8
 #define IXGBE_DEV_ID_82598EB_CX4         0x10DD
+#define IXGBE_DEV_ID_82598_CX4_DUAL_PORT 0x10EC
 
 /* General Registers */
 #define IXGBE_CTRL      0x00000

