From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] virtchnl: Add pad fields to a couple of structures
Date: Thu,  1 Jun 2017 14:38:37 -0700
Message-ID: <20170601213840.36286-12-jeffrey.t.kirsher@intel.com>
References: <20170601213840.36286-1-jeffrey.t.kirsher@intel.com>
Cc: Sridhar Samudrala <sridhar.samudrala@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:12166 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751122AbdFAVjD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 17:39:03 -0400
In-Reply-To: <20170601213840.36286-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

This removes holes and makes structure sizes consistent across
32 and 64 bit builds.

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/avf/virtchnl.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/avf/virtchnl.h b/include/linux/avf/virtchnl.h
index dab76e947b9f..72466c69f749 100644
--- a/include/linux/avf/virtchnl.h
+++ b/include/linux/avf/virtchnl.h
@@ -275,8 +275,10 @@ struct virtchnl_rxq_info {
 	u16 splithdr_enabled; /* deprecated with AVF 1.0 */
 	u32 databuffer_size;
 	u32 max_pkt_size;
+	u32 pad1;
 	u64 dma_ring_addr;
 	enum virtchnl_rx_hsplit rx_split_pos; /* deprecated with AVF 1.0 */
+	u32 pad2;
 };
 
 /* VIRTCHNL_OP_CONFIG_VSI_QUEUES
@@ -295,6 +297,7 @@ struct virtchnl_queue_pair_info {
 struct virtchnl_vsi_queue_config_info {
 	u16 vsi_id;
 	u16 num_queue_pairs;
+	u32 pad;
 	struct virtchnl_queue_pair_info qpair[1];
 };
 
-- 
2.12.2
