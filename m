From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/4] ixgbe: Add device support for a new copper
	82598 device
Date: Thu, 16 Jul 2009 18:50:52 -0700
Message-ID: <20090717015051.24074.6624.stgit@localhost.localdomain>
References: <20090717014951.24074.75893.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:45296
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757613AbZGQBvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 21:51:10 -0400
In-Reply-To: <20090717014951.24074.75893.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

This adds support for a new copper device for 82598, device id 0x150b.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c |    1 +
 drivers/net/ixgbe/ixgbe_main.c  |    2 ++
 drivers/net/ixgbe/ixgbe_type.h  |    1 +
 3 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index b992304..ed0bb3b 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -269,6 +269,7 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
 		media_type = ixgbe_media_type_fiber;
 		break;
 	case IXGBE_DEV_ID_82598AT:
+	case IXGBE_DEV_ID_82598AT2:
 		media_type = ixgbe_media_type_copper;
 		break;
 	default:
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 09394c1..a3bbcfd 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -74,6 +74,8 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AT),
 	 board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AT2),
+	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598EB_CX4),
 	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598_CX4_DUAL_PORT),
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 8fb6ade..17ee389 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -42,6 +42,7 @@
 #define IXGBE_DEV_ID_82598AF_SINGLE_PORT 0x10C7
 #define IXGBE_DEV_ID_82598EB_SFP_LOM     0x10DB
 #define IXGBE_DEV_ID_82598AT             0x10C8
+#define IXGBE_DEV_ID_82598AT2            0x150B
 #define IXGBE_DEV_ID_82598EB_CX4         0x10DD
 #define IXGBE_DEV_ID_82598_CX4_DUAL_PORT 0x10EC
 #define IXGBE_DEV_ID_82598_DA_DUAL_PORT  0x10F1

