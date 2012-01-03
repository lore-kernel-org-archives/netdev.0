From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/7] ixgbe: fix typo's
Date: Mon,  2 Jan 2012 17:50:48 -0800
Message-ID: <1325555451-4697-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1325555451-4697-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18965 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751178Ab2ACBu4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jan 2012 20:50:56 -0500
In-Reply-To: <1325555451-4697-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>

Saw typo in one message, so decided to run spell checker.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index fcf8d4e..cd1f893 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -146,7 +146,7 @@ static void ixgbe_service_event_complete(struct ixgbe_adapter *adapter)
 {
 	BUG_ON(!test_bit(__IXGBE_SERVICE_SCHED, &adapter->state));
 
-	/* flush memory to make sure state is correct before next watchog */
+	/* flush memory to make sure state is correct before next watchdog */
 	smp_mb__before_clear_bit();
 	clear_bit(__IXGBE_SERVICE_SCHED, &adapter->state);
 }
@@ -2156,7 +2156,7 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	IXGBE_WRITE_REG(hw, IXGBE_EIMC, IXGBE_IRQ_CLEAR_MASK);
 
 	/* for NAPI, using EIAM to auto-mask tx/rx interrupt bits on read
-	 * therefore no explict interrupt disable is necessary */
+	 * therefore no explicit interrupt disable is necessary */
 	eicr = IXGBE_READ_REG(hw, IXGBE_EICR);
 	if (!eicr) {
 		/*
@@ -3606,7 +3606,7 @@ static inline bool ixgbe_is_sfp(struct ixgbe_hw *hw)
 static void ixgbe_sfp_link_config(struct ixgbe_adapter *adapter)
 {
 	/*
-	 * We are assuming the worst case scenerio here, and that
+	 * We are assuming the worst case scenario here, and that
 	 * is that an SFP was inserted/removed after the reset
 	 * but before SFP detection was enabled.  As such the best
 	 * solution is to just start searching as soon as we start
@@ -3828,7 +3828,7 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 	case IXGBE_ERR_EEPROM_VERSION:
 		/* We are running on a pre-production device, log a warning */
 		e_dev_warn("This device is a pre-production adapter/LOM. "
-			   "Please be aware there may be issuesassociated with "
+			   "Please be aware there may be issues associated with "
 			   "your hardware.  If you are experiencing problems "
 			   "please contact your Intel or hardware "
 			   "representative who provided you with this "
@@ -5792,9 +5792,9 @@ static void ixgbe_fdir_reinit_subtask(struct ixgbe_adapter *adapter)
  * @adapter - pointer to the device adapter structure
  *
  * This function serves two purposes.  First it strobes the interrupt lines
- * in order to make certain interrupts are occuring.  Secondly it sets the
+ * in order to make certain interrupts are occurring.  Secondly it sets the
  * bits needed to check for TX hangs.  As a result we should immediately
- * determine if a hang has occured.
+ * determine if a hang has occurred.
  */
 static void ixgbe_check_hang_subtask(struct ixgbe_adapter *adapter)
 {
@@ -7132,7 +7132,7 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 		return -EINVAL;
 
 	/* Hardware has to reinitialize queues and interrupts to
-	 * match packet buffer alignment. Unfortunantly, the
+	 * match packet buffer alignment. Unfortunately, the
 	 * hardware is not flexible enough to do this dynamically.
 	 */
 	if (netif_running(dev))
-- 
1.7.7.4
