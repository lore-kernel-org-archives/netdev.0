From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] ixgbe: add support for 82599 based X520 10G Dual
	KX4 Mezz card
Date: Fri, 02 Oct 2009 11:58:25 -0700
Message-ID: <20091002185825.8771.50867.stgit@localhost.localdomain>
References: <20091002185803.8771.46655.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:49923
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755434AbZJBS7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 14:59:39 -0400
In-Reply-To: <20091002185803.8771.46655.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch adds device support for the 82599 based X520 10GbE
Dual Port KX4 Mezzanine card.

Signed-off-by: Don Skidmore<donald.c.skidmore@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |    1 +
 drivers/net/ixgbe/ixgbe_main.c  |    2 ++
 drivers/net/ixgbe/ixgbe_type.h  |    1 +
 3 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index bb87c43..34b0492 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -330,6 +330,7 @@ static enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw)
 
 	switch (hw->device_id) {
 	case IXGBE_DEV_ID_82599_KX4:
+	case IXGBE_DEV_ID_82599_KX4_MEZZ:
 	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
 	case IXGBE_DEV_ID_82599_XAUI_LOM:
 		/* Default device ID is mezzanine card KX/KX4 */
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index dc4afa5..1a2eb79 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -97,6 +97,8 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 	 board_82599 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP),
 	 board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_KX4_MEZZ),
+	 board_82599 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_CX4),
 	 board_82599 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_COMBO_BACKPLANE),
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index a71f712..ef4bdd5 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -49,6 +49,7 @@
 #define IXGBE_DEV_ID_82598_SR_DUAL_PORT_EM      0x10E1
 #define IXGBE_DEV_ID_82598EB_XF_LR       0x10F4
 #define IXGBE_DEV_ID_82599_KX4           0x10F7
+#define IXGBE_DEV_ID_82599_KX4_MEZZ      0x1514
 #define IXGBE_DEV_ID_82599_CX4           0x10F9
 #define IXGBE_DEV_ID_82599_SFP           0x10FB
 #define IXGBE_DEV_ID_82599_XAUI_LOM      0x10FC

