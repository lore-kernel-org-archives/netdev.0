From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 3/7] ixgbevf: Fix name of function in function header comment
Date: Thu, 24 Feb 2011 02:58:25 -0800
Message-ID: <1298545109-8990-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1298545109-8990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8720 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753123Ab1BXK6g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Feb 2011 05:58:36 -0500
In-Reply-To: <1298545109-8990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Some of the function names in function header comments did not match
actual name of the function.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbevf/ixgbevf_main.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 1f36f8f..43af761 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -107,7 +107,7 @@ static inline void ixgbevf_release_rx_desc(struct ixgbe_hw *hw,
 }
 
 /*
- * ixgbe_set_ivar - set the IVAR registers, mapping interrupt causes to vectors
+ * ixgbevf_set_ivar - set IVAR registers - maps interrupt causes to vectors
  * @adapter: pointer to adapter struct
  * @direction: 0 for Rx, 1 for Tx, -1 for other causes
  * @queue: queue to map the corresponding interrupt to
@@ -1017,7 +1017,7 @@ static irqreturn_t ixgbevf_msix_clean_tx(int irq, void *data)
 }
 
 /**
- * ixgbe_msix_clean_rx - single unshared vector rx clean (all queues)
+ * ixgbevf_msix_clean_rx - single unshared vector rx clean (all queues)
  * @irq: unused
  * @data: pointer to our q_vector struct for this interrupt vector
  **/
@@ -1972,7 +1972,7 @@ static void ixgbevf_acquire_msix_vectors(struct ixgbevf_adapter *adapter,
 }
 
 /*
- * ixgbe_set_num_queues: Allocate queues for device, feature dependant
+ * ixgbevf_set_num_queues: Allocate queues for device, feature dependant
  * @adapter: board private structure to initialize
  *
  * This is the top level queue allocation routine.  The order here is very
@@ -3534,9 +3534,9 @@ static struct pci_driver ixgbevf_driver = {
 };
 
 /**
- * ixgbe_init_module - Driver Registration Routine
+ * ixgbevf_init_module - Driver Registration Routine
  *
- * ixgbe_init_module is the first routine called when the driver is
+ * ixgbevf_init_module is the first routine called when the driver is
  * loaded. All it does is register with the PCI subsystem.
  **/
 static int __init ixgbevf_init_module(void)
@@ -3554,9 +3554,9 @@ static int __init ixgbevf_init_module(void)
 module_init(ixgbevf_init_module);
 
 /**
- * ixgbe_exit_module - Driver Exit Cleanup Routine
+ * ixgbevf_exit_module - Driver Exit Cleanup Routine
  *
- * ixgbe_exit_module is called just before the driver is removed
+ * ixgbevf_exit_module is called just before the driver is removed
  * from memory.
  **/
 static void __exit ixgbevf_exit_module(void)
@@ -3566,7 +3566,7 @@ static void __exit ixgbevf_exit_module(void)
 
 #ifdef DEBUG
 /**
- * ixgbe_get_hw_dev_name - return device name string
+ * ixgbevf_get_hw_dev_name - return device name string
  * used by hardware layer to print debugging information
  **/
 char *ixgbevf_get_hw_dev_name(struct ixgbe_hw *hw)
-- 
1.7.4

