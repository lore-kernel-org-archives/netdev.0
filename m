From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e/i40evf: Change type to u32 to avoid sparse error
Date: Thu, 29 May 2014 08:10:11 -0700
Message-ID: <1401376216-12531-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51814 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932901AbaE2PKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:10:37 -0400
In-Reply-To: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

tx_lpi_status and rx_lpi_status are declared as bool but then used in sizeof
operations in the CORE driver code.  Make them u32 to make sparse be quiet.

Change-ID: Iad6daeb1c7149e61ece242acd18c64b320c246a3
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 0fe158c..71f9718 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -1016,8 +1016,8 @@ struct i40e_hw_port_stats {
 	u64 mac_short_packet_dropped;	/* mspdc */
 	u64 checksum_error;		/* xec */
 	/* EEE LPI */
-	bool tx_lpi_status;
-	bool rx_lpi_status;
+	u32 tx_lpi_status;
+	u32 rx_lpi_status;
 	u64 tx_lpi_count;		/* etlpic */
 	u64 rx_lpi_count;		/* erlpic */
 };
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index c854cca..67082f7 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -1016,8 +1016,8 @@ struct i40e_hw_port_stats {
 	u64 mac_short_packet_dropped;	/* mspdc */
 	u64 checksum_error;		/* xec */
 	/* EEE LPI */
-	bool tx_lpi_status;
-	bool rx_lpi_status;
+	u32 tx_lpi_status;
+	u32 rx_lpi_status;
 	u64 tx_lpi_count;		/* etlpic */
 	u64 rx_lpi_count;		/* erlpic */
 };
-- 
1.9.3
