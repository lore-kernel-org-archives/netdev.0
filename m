From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] ixgbe: remove device ID for unsupported device
Date: Fri, 11 Jul 2008 17:34:58 -0700
Message-ID: <20080712003458.21801.63058.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, stable@kernel.org, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4960 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754807AbYGLAfD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 20:35:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The ixgbe driver was untested with device ID 8086:10c8 but still advertises
support.  Currently if this device is present in the system when the driver
is loaded, the system will panic.
Remove this device ID until full support can be tested with available
hardware.  This patch is necessary for 2.6.24, 2.6.25 and 2.6.26

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 8f04609..e248f80 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -70,8 +70,6 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AF_SINGLE_PORT),
 	 board_82598 },
-	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AT_DUAL_PORT),
-	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598EB_CX4),
 	 board_82598 },
 

