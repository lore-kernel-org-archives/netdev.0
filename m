From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/13] igb: reduce Rx header size
Date: Thu, 23 Aug 2012 02:56:49 -0700
Message-ID: <1345715813-20757-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16367 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758310Ab2HWJ5B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 05:57:01 -0400
In-Reply-To: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Reduce skb truesize by 256 bytes.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 9e572dd..0c9f62c 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -131,9 +131,9 @@ struct vf_data_storage {
 #define MAXIMUM_ETHERNET_VLAN_SIZE 1522
 
 /* Supported Rx Buffer Sizes */
-#define IGB_RXBUFFER_512   512
+#define IGB_RXBUFFER_256   256
 #define IGB_RXBUFFER_16384 16384
-#define IGB_RX_HDR_LEN     IGB_RXBUFFER_512
+#define IGB_RX_HDR_LEN     IGB_RXBUFFER_256
 
 /* How many Tx Descriptors do we need to call netif_wake_queue ? */
 #define IGB_TX_QUEUE_WAKE	16
-- 
1.7.11.4
