From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] e1000e: cleanup: remove comments which are no longer applicable
Date: Mon, 28 Jan 2013 01:04:26 -0800
Message-ID: <1359363869-32391-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47947 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754532Ab3A1JEk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 04:04:40 -0500
In-Reply-To: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Code was removed but the applicable comments were not.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/defines.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
index c458767..d29b2fd 100644
--- a/drivers/net/ethernet/intel/e1000e/defines.h
+++ b/drivers/net/ethernet/intel/e1000e/defines.h
@@ -261,8 +261,6 @@
 #define E1000_STATUS_PHYRA      0x00000400      /* PHY Reset Asserted */
 #define E1000_STATUS_GIO_MASTER_ENABLE 0x00080000 /* Status of Master requests. */
 
-/* Constants used to interpret the masked PCI-X bus speed. */
-
 #define HALF_DUPLEX 1
 #define FULL_DUPLEX 2
 
@@ -330,8 +328,6 @@
 #define E1000_TCTL_RTLC   0x01000000    /* Re-transmit on late collision */
 #define E1000_TCTL_MULR   0x10000000    /* Multiple request support */
 
-/* Transmit Arbitration Count */
-
 /* SerDes Control */
 #define E1000_SCTL_DISABLE_SERDES_LOOPBACK 0x0400
 
@@ -800,9 +796,6 @@
 #define M88E1000_PSCR_AUTO_X_1000T     0x0040
 /* Auto crossover enabled all speeds */
 #define M88E1000_PSCR_AUTO_X_MODE      0x0060
-/* 1=Enable Extended 10BASE-T distance (Lower 10BASE-T Rx Threshold)
- * 0=Normal 10BASE-T Rx Threshold
- */
 #define M88E1000_PSCR_ASSERT_CRS_ON_TX 0x0800 /* 1=Assert CRS on Transmit */
 
 /* M88E1000 PHY Specific Status Register */
-- 
1.7.11.7
