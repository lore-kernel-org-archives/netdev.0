From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] e1000e: cleanup LEADING_SPACE checkpatch warnings
Date: Fri,  8 Mar 2013 02:07:08 -0800
Message-ID: <1362737237-13363-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51324 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933944Ab3CHKH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 05:07:29 -0500
In-Reply-To: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

WARNING:LEADING_SPACE: please, no spaces at the start of a line

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h  |  4 ++--
 drivers/net/ethernet/intel/e1000e/netdev.c |  4 ++--
 drivers/net/ethernet/intel/e1000e/phy.c    | 10 +++++-----
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 9b6a568..6ce64ae 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -487,8 +487,8 @@ extern int e1000e_setup_tx_resources(struct e1000_ring *ring);
 extern void e1000e_free_rx_resources(struct e1000_ring *ring);
 extern void e1000e_free_tx_resources(struct e1000_ring *ring);
 extern struct rtnl_link_stats64 *e1000e_get_stats64(struct net_device *netdev,
-                                                    struct rtnl_link_stats64
-                                                    *stats);
+						    struct rtnl_link_stats64
+						    *stats);
 extern void e1000e_set_interrupt_capability(struct e1000_adapter *adapter);
 extern void e1000e_reset_interrupt_capability(struct e1000_adapter *adapter);
 extern void e1000e_get_hw_control(struct e1000_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 1fa61ca..87fa1c9 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1468,7 +1468,7 @@ next_desc:
  * e1000_consume_page - helper function
  **/
 static void e1000_consume_page(struct e1000_buffer *bi, struct sk_buff *skb,
-                               u16 length)
+			       u16 length)
 {
 	bi->page = NULL;
 	skb->len += length;
@@ -5571,7 +5571,7 @@ static void e1000_reset_task(struct work_struct *work)
  * Returns the address of the device statistics structure.
  **/
 struct rtnl_link_stats64 *e1000e_get_stats64(struct net_device *netdev,
-                                             struct rtnl_link_stats64 *stats)
+					     struct rtnl_link_stats64 *stats)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index e46b65f..643353f 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -324,7 +324,7 @@ s32 e1000_set_page_igp(struct e1000_hw *hw, u16 page)
  *  semaphores before exiting.
  **/
 static s32 __e1000e_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data,
-                                    bool locked)
+				     bool locked)
 {
 	s32 ret_val = 0;
 
@@ -391,7 +391,7 @@ s32 e1000e_read_phy_reg_igp_locked(struct e1000_hw *hw, u32 offset, u16 *data)
  *  at the offset.  Release any acquired semaphores before exiting.
  **/
 static s32 __e1000e_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data,
-                                     bool locked)
+				      bool locked)
 {
 	s32 ret_val = 0;
 
@@ -458,7 +458,7 @@ s32 e1000e_write_phy_reg_igp_locked(struct e1000_hw *hw, u32 offset, u16 data)
  *  Release any acquired semaphores before exiting.
  **/
 static s32 __e1000_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data,
-                                 bool locked)
+				 bool locked)
 {
 	u32 kmrnctrlsta;
 
@@ -531,7 +531,7 @@ s32 e1000e_read_kmrn_reg_locked(struct e1000_hw *hw, u32 offset, u16 *data)
  *  before exiting.
  **/
 static s32 __e1000_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data,
-                                  bool locked)
+				  bool locked)
 {
 	u32 kmrnctrlsta;
 
@@ -2987,7 +2987,7 @@ static u32 e1000_get_phy_addr_for_hv_page(u32 page)
  *  These accesses done with PHY address 2 and without using pages.
  **/
 static s32 e1000_access_phy_debug_regs_hv(struct e1000_hw *hw, u32 offset,
-                                          u16 *data, bool read)
+					  u16 *data, bool read)
 {
 	s32 ret_val;
 	u32 addr_reg;
-- 
1.7.11.7
