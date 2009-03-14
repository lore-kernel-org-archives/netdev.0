From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 7/8] igb: add support for another dual port 82576
	non-security nic
Date: Fri, 13 Mar 2009 23:42:15 -0700
Message-ID: <20090314064215.4052.64563.stgit@lost.foo-projects.org>
References: <20090314064020.4052.46249.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:45652 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752370AbZCNGmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 02:42:36 -0400
In-Reply-To: <20090314064020.4052.46249.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Adding device id to support 82576NS dual port copper
NIC.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |    1 +
 drivers/net/igb/e1000_hw.h    |    1 +
 drivers/net/igb/igb_main.c    |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index ea63a21..adfe2e1 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -80,6 +80,7 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 		mac->type = e1000_82575;
 		break;
 	case E1000_DEV_ID_82576:
+	case E1000_DEV_ID_82576_NS:
 	case E1000_DEV_ID_82576_FIBER:
 	case E1000_DEV_ID_82576_SERDES:
 		mac->type = e1000_82576;
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index d793dca..4db3602 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -40,6 +40,7 @@ struct e1000_hw;
 #define E1000_DEV_ID_82576                    0x10C9
 #define E1000_DEV_ID_82576_FIBER              0x10E6
 #define E1000_DEV_ID_82576_SERDES             0x10E7
+#define E1000_DEV_ID_82576_NS                 0x150A
 #define E1000_DEV_ID_82575EB_COPPER           0x10A7
 #define E1000_DEV_ID_82575EB_FIBER_SERDES     0x10A9
 #define E1000_DEV_ID_82575GB_QUAD_COPPER      0x10D6
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 3f505ae..0997370 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -62,6 +62,7 @@ static const struct e1000_info *igb_info_tbl[] = {
 
 static struct pci_device_id igb_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576), board_82575 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_NS), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_FIBER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_SERDES), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82575EB_COPPER), board_82575 },

