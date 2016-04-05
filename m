From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/16] fm10k: fix a minor typo in some comments
Date: Tue,  5 Apr 2016 01:01:27 -0700
Message-ID: <1459843288-40623-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:25315 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755389AbcDEIC1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 04:02:27 -0400
In-Reply-To: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

s/funciton/function to resolve a typo, and cleanup grammar on a few
comments regarding processing the VF mailboxes.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c    | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    | 6 +++---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c     | 2 +-
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
index acfb8b1f..bbf7c4b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
@@ -50,7 +50,7 @@ s32 fm10k_iov_event(struct fm10k_intfc *interface)
 	s64 vflre;
 	int i;
 
-	/* if there is no iov_data then there is no mailboxes to process */
+	/* if there is no iov_data then there is no mailbox to process */
 	if (!ACCESS_ONCE(interface->iov_data))
 		return 0;
 
@@ -98,7 +98,7 @@ s32 fm10k_iov_mbx(struct fm10k_intfc *interface)
 	struct fm10k_iov_data *iov_data;
 	int i;
 
-	/* if there is no iov_data then there is no mailboxes to process */
+	/* if there is no iov_data then there is no mailbox to process */
 	if (!ACCESS_ONCE(interface->iov_data))
 		return 0;
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 0ff6874..1d0f058 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -440,7 +440,7 @@ static void fm10k_restore_vxlan_port(struct fm10k_intfc *interface)
  * @sa_family: Address family of new port
  * @port: port number used for VXLAN
  *
- * This funciton is called when a new VXLAN interface has added a new port
+ * This function is called when a new VXLAN interface has added a new port
  * number to the range that is currently in use for VXLAN.  The new port
  * number is always added to the tail so that the port number list should
  * match the order in which the ports were allocated.  The head of the list
@@ -484,7 +484,7 @@ insert_tail:
  * @sa_family: Address family of freed port
  * @port: port number used for VXLAN
  *
- * This funciton is called when a new VXLAN interface has freed a port
+ * This function is called when a new VXLAN interface has freed a port
  * number from the range that is currently in use for VXLAN.  The freed
  * port is removed from the list and the new head is used to determine
  * the port number for offloads.
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index da38af0..f099295 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1379,7 +1379,7 @@ static s32 fm10k_1588_msg_pf(struct fm10k_hw *hw, u32 **results,
 		return 0;
 	}
 
-	/* if there is no iov_data then there is no mailboxes to process */
+	/* if there is no iov_data then there is no mailbox to process */
 	if (!ACCESS_ONCE(interface->iov_data))
 		return FM10K_ERR_PARAM;
 
@@ -2394,7 +2394,7 @@ static struct pci_driver fm10k_driver = {
 /**
  * fm10k_register_pci_driver - register driver interface
  *
- * This funciton is called on module load in order to register the driver.
+ * This function is called on module load in order to register the driver.
  **/
 int fm10k_register_pci_driver(void)
 {
@@ -2404,7 +2404,7 @@ int fm10k_register_pci_driver(void)
 /**
  * fm10k_unregister_pci_driver - unregister driver interface
  *
- * This funciton is called on module unload in order to remove the driver.
+ * This function is called on module unload in order to remove the driver.
  **/
 void fm10k_unregister_pci_driver(void)
 {
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 23de956..ecc99f9 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1604,7 +1604,7 @@ static s32 fm10k_request_lport_map_pf(struct fm10k_hw *hw)
  *  @hw: pointer to hardware structure
  *  @switch_ready: pointer to boolean value that will record switch state
  *
- *  This funciton will check the DMA_CTRL2 register and mailbox in order
+ *  This function will check the DMA_CTRL2 register and mailbox in order
  *  to determine if the switch is ready for the PF to begin requesting
  *  addresses and mapping traffic to the local interface.
  **/
-- 
2.5.5
