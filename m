From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/17] i40e: add missing kernel-doc argument
Date: Fri, 23 Oct 2015 06:17:53 -0700
Message-ID: <1445606279-19345-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61352 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752264AbbJWNST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 09:18:19 -0400
In-Reply-To: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

The following kernel-doc arguments for their respective functions are
missing:

1) @cd_type_cmd_tso_mss for i40e_tso();
2) @cd_type_cmd_tso_mss for i40e_tsyn();
3) @tx_ring for i40e_tx_enable_csum().

Add them all for the kernel-doc requirement.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 006f0fb..635b3ac 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2187,6 +2187,7 @@ out:
  * @tx_ring:  ptr to the ring to send
  * @skb:      ptr to the skb we're sending
  * @hdr_len:  ptr to the size of the packet header
+ * @cd_type_cmd_tso_mss: ptr to u64 object
  * @cd_tunneling: ptr to context descriptor bits
  *
  * Returns 0 if no TSO can happen, 1 if tso is going, or error
@@ -2246,6 +2247,7 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
  * @tx_ring:  ptr to the ring to send
  * @skb:      ptr to the skb we're sending
  * @tx_flags: the collected send information
+ * @cd_type_cmd_tso_mss: ptr to u64 object
  *
  * Returns 0 if no Tx timestamp can happen and 1 if the timestamp will happen
  **/
@@ -2288,6 +2290,7 @@ static int i40e_tsyn(struct i40e_ring *tx_ring, struct sk_buff *skb,
  * @tx_flags: pointer to Tx flags currently set
  * @td_cmd: Tx descriptor command bits to set
  * @td_offset: Tx descriptor header offsets to set
+ * @tx_ring: Tx descriptor ring
  * @cd_tunneling: ptr to context desc bits
  **/
 static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
-- 
2.4.3
