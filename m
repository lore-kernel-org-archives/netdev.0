From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/3] ixgbe: Add support for 82599-based CX4 adapters
Date: Mon, 14 Sep 2009 10:47:49 -0700
Message-ID: <20090914174748.4560.39373.stgit@localhost.localdomain>
References: <20090914174659.4560.28814.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:43481
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751063AbZINRsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 13:48:06 -0400
In-Reply-To: <20090914174659.4560.28814.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

This patch adds support for CX4 adapters based on 82599.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |    3 +++
 drivers/net/ixgbe/ixgbe_main.c  |    2 ++
 drivers/net/ixgbe/ixgbe_type.h  |    1 +
 3 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 61af47e..c9006bb 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -337,6 +337,9 @@ static enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_82599_SFP:
 		media_type = ixgbe_media_type_fiber;
 		break;
+	case IXGBE_DEV_ID_82599_CX4:
+		media_type = ixgbe_media_type_fiber;
+		break;
 	default:
 		media_type = ixgbe_media_type_unknown;
 		break;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b47aaa8..59ad959 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -97,6 +97,8 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 	 board_82599 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP),
 	 board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_CX4),
+	 board_82599 },
 
 	/* required last entry */
 	{0, }
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 8ba90ee..37303a1 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -49,6 +49,7 @@
 #define IXGBE_DEV_ID_82598_SR_DUAL_PORT_EM      0x10E1
 #define IXGBE_DEV_ID_82598EB_XF_LR       0x10F4
 #define IXGBE_DEV_ID_82599_KX4           0x10F7
+#define IXGBE_DEV_ID_82599_CX4           0x10F9
 #define IXGBE_DEV_ID_82599_SFP           0x10FB
 #define IXGBE_DEV_ID_82599_XAUI_LOM      0x10FC
 

