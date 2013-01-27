From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] e1000e: remove definition of struct which is no longer used
Date: Sun, 27 Jan 2013 02:39:49 -0800
Message-ID: <1359283193-2043-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35700 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756533Ab3A0KkE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2013 05:40:04 -0500
In-Reply-To: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The e1000e driver has been converted to use extended descriptors instead of
the older legacy descriptor type.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/hw.h | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/hw.h b/drivers/net/ethernet/intel/e1000e/hw.h
index 0a08b14..a10de4d 100644
--- a/drivers/net/ethernet/intel/e1000e/hw.h
+++ b/drivers/net/ethernet/intel/e1000e/hw.h
@@ -542,16 +542,6 @@ enum e1000_serdes_link_state {
 	e1000_serdes_link_forced_up
 };
 
-/* Receive Descriptor */
-struct e1000_rx_desc {
-	__le64 buffer_addr; /* Address of the descriptor's data buffer */
-	__le16 length;      /* Length of data DMAed into data buffer */
-	__le16 csum;	/* Packet checksum */
-	u8  status;      /* Descriptor status */
-	u8  errors;      /* Descriptor Errors */
-	__le16 special;
-};
-
 /* Receive Descriptor - Extended */
 union e1000_rx_desc_extended {
 	struct {
-- 
1.7.11.7
