From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 02/17] i40e: drop unused macros
Date: Fri, 10 Jan 2014 16:47:15 -0800
Message-ID: <1389401250-11509-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389401250-11509-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:25626 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751202AbaAKArh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 19:47:37 -0500
In-Reply-To: <1389401250-11509-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

A previous commit removed any need for these macros, so remove
them too.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_type.h | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 12473ad..072c850 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -60,15 +60,6 @@
 /* Max default timeout in ms, */
 #define I40E_MAX_NVM_TIMEOUT		18000
 
-/* Check whether address is multicast.  This is little-endian specific check.*/
-#define I40E_IS_MULTICAST(address)	\
-	(bool)(((u8 *)(address))[0] & ((u8)0x01))
-
-/* Check whether an address is broadcast. */
-#define I40E_IS_BROADCAST(address)	\
-	((((u8 *)(address))[0] == ((u8)0xff)) && \
-	(((u8 *)(address))[1] == ((u8)0xff)))
-
 /* Switch from mc to the 2usec global time (this is the GTIME resolution) */
 #define I40E_MS_TO_GTIME(time)		(((time) * 1000) / 2)
 
-- 
1.8.3.1
