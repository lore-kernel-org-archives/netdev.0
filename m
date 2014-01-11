From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 11/17] i40e: adjust ITR max and min values
Date: Fri, 10 Jan 2014 16:47:24 -0800
Message-ID: <1389401250-11509-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389401250-11509-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64975 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752361AbaAKArr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 19:47:47 -0500
In-Reply-To: <1389401250-11509-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Set the ITR max and min values to match the hardware max value
and the recommended min value.  These values are shifted right
one bit because the register counts in 2 usec units, so leave
a comment to explain.

Change-ID: I289c27955cf6c566a6d21b95c3110b88cbb15dad
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 6f8506c..93b8642 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -29,9 +29,8 @@
 
 /* Interrupt Throttling and Rate Limiting (storm control) Goodies */
 
-#define I40E_MAX_ITR               0x07FF
-#define I40E_MIN_ITR               0x0001
-#define I40E_ITR_USEC_RESOLUTION   2
+#define I40E_MAX_ITR               0x0FF0  /* reg uses 2 usec resolution */
+#define I40E_MIN_ITR               0x0004  /* reg uses 2 usec resolution */
 #define I40E_MAX_IRATE             0x03F
 #define I40E_MIN_IRATE             0x001
 #define I40E_IRATE_USEC_RESOLUTION 4
-- 
1.8.3.1
