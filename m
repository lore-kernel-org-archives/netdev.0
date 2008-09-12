From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 14/29] ixgbe: add device support for XF LR
	adapters
Date: Thu, 11 Sep 2008 19:58:59 -0700
Message-ID: <20080912025847.6234.68977.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:45474 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754791AbYILC7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 22:59:02 -0400
Received: by wa-out-1112.google.com with SMTP id j37so392897waf.23
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 19:59:01 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c |    1 +
 drivers/net/ixgbe/ixgbe_main.c  |    2 ++
 drivers/net/ixgbe/ixgbe_type.h  |    1 +
 3 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 1e014bc..0726140 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -196,6 +196,7 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_82598AF_SINGLE_PORT:
 	case IXGBE_DEV_ID_82598EB_CX4:
 	case IXGBE_DEV_ID_82598_CX4_DUAL_PORT:
+	case IXGBE_DEV_ID_82598EB_XF_LR:
 		media_type = ixgbe_media_type_fiber;
 		break;
 	case IXGBE_DEV_ID_82598AT_DUAL_PORT:
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5858ab2..3b0481a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -74,6 +74,8 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598_CX4_DUAL_PORT),
 	 board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598EB_XF_LR),
+	 board_82598 },
 
 	/* required last entry */
 	{0, }
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 196841b..7057aa3 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -40,6 +40,7 @@
 #define IXGBE_DEV_ID_82598AT_DUAL_PORT   0x10C8
 #define IXGBE_DEV_ID_82598EB_CX4         0x10DD
 #define IXGBE_DEV_ID_82598_CX4_DUAL_PORT 0x10EC
+#define IXGBE_DEV_ID_82598EB_XF_LR       0x10F4
 
 /* General Registers */
 #define IXGBE_CTRL      0x00000

