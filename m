From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: trivial: formatting and checkpatch fixes
Date: Thu,  9 Jan 2014 04:52:21 -0800
Message-ID: <1389271944-26227-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55960 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755192AbaAIMwl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:52:41 -0500
In-Reply-To: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Fix some badly formatted lines, long lines and a mis-formatted else.

Change-ID: Iac2eef064ae27c55a0c3d9c15c525bf8fed8ab6f
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 30 +++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  3 ++-
 2 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5245ebb..43d88dd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -990,15 +990,15 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 		skb = rx_bi->skb;
 		prefetch(skb->data);
 
-		rx_packet_len = (qword & I40E_RXD_QW1_LENGTH_PBUF_MASK)
-					      >> I40E_RXD_QW1_LENGTH_PBUF_SHIFT;
-		rx_header_len = (qword & I40E_RXD_QW1_LENGTH_HBUF_MASK)
-					      >> I40E_RXD_QW1_LENGTH_HBUF_SHIFT;
-		rx_sph = (qword & I40E_RXD_QW1_LENGTH_SPH_MASK)
-					      >> I40E_RXD_QW1_LENGTH_SPH_SHIFT;
-
-		rx_error = (qword & I40E_RXD_QW1_ERROR_MASK)
-					      >> I40E_RXD_QW1_ERROR_SHIFT;
+		rx_packet_len = (qword & I40E_RXD_QW1_LENGTH_PBUF_MASK) >>
+				I40E_RXD_QW1_LENGTH_PBUF_SHIFT;
+		rx_header_len = (qword & I40E_RXD_QW1_LENGTH_HBUF_MASK) >>
+				I40E_RXD_QW1_LENGTH_HBUF_SHIFT;
+		rx_sph = (qword & I40E_RXD_QW1_LENGTH_SPH_MASK) >>
+			 I40E_RXD_QW1_LENGTH_SPH_SHIFT;
+
+		rx_error = (qword & I40E_RXD_QW1_ERROR_MASK) >>
+			   I40E_RXD_QW1_ERROR_SHIFT;
 		rx_hbo = rx_error & (1 << I40E_RX_DESC_ERROR_HBO_SHIFT);
 		rx_error &= ~(1 << I40E_RX_DESC_ERROR_HBO_SHIFT);
 
@@ -1114,8 +1114,8 @@ next_desc:
 		/* use prefetched values */
 		rx_desc = next_rxd;
 		qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
-		rx_status = (qword & I40E_RXD_QW1_STATUS_MASK)
-						>> I40E_RXD_QW1_STATUS_SHIFT;
+		rx_status = (qword & I40E_RXD_QW1_STATUS_MASK) >>
+			    I40E_RXD_QW1_STATUS_SHIFT;
 	}
 
 	rx_ring->next_to_clean = i;
@@ -1414,10 +1414,10 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	cd_cmd = I40E_TX_CTX_DESC_TSO;
 	cd_tso_len = skb->len - *hdr_len;
 	cd_mss = skb_shinfo(skb)->gso_size;
-	*cd_type_cmd_tso_mss |= ((u64)cd_cmd << I40E_TXD_CTX_QW1_CMD_SHIFT)
-			     | ((u64)cd_tso_len
-				<< I40E_TXD_CTX_QW1_TSO_LEN_SHIFT)
-			     | ((u64)cd_mss << I40E_TXD_CTX_QW1_MSS_SHIFT);
+	*cd_type_cmd_tso_mss |= ((u64)cd_cmd << I40E_TXD_CTX_QW1_CMD_SHIFT) |
+				((u64)cd_tso_len <<
+				 I40E_TXD_CTX_QW1_TSO_LEN_SHIFT) |
+				((u64)cd_mss << I40E_TXD_CTX_QW1_MSS_SHIFT);
 	return 1;
 }
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 66fffbd..51a4f61 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -176,7 +176,8 @@ static void i40e_config_irq_link_list(struct i40e_vf *vf, u16 vsi_idx,
 				       (I40E_MAX_VSI_QP *
 					I40E_VIRTCHNL_SUPPORTED_QTYPES),
 				       next_q + 1);
-		if (next_q < (I40E_MAX_VSI_QP * I40E_VIRTCHNL_SUPPORTED_QTYPES)) {
+		if (next_q <
+		    (I40E_MAX_VSI_QP * I40E_VIRTCHNL_SUPPORTED_QTYPES)) {
 			vsi_queue_id = next_q / I40E_VIRTCHNL_SUPPORTED_QTYPES;
 			qtype = next_q % I40E_VIRTCHNL_SUPPORTED_QTYPES;
 			pf_queue_id = i40e_vc_get_pf_queue_id(vf, vsi_idx,
-- 
1.8.3.1
