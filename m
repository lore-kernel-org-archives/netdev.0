From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 03/17] i40e: Update the Current NVM version Low value
Date: Fri, 10 Jan 2014 16:47:16 -0800
Message-ID: <1389401250-11509-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389401250-11509-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47344 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751303AbaAKAri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 19:47:38 -0500
In-Reply-To: <1389401250-11509-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

The current driver will warn the user if the NVM version
is out of date, this raises the bar to a newer version.

Change-ID: I5ec21d8efa4e7c3fdacb56f85d310bb2229b1483
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 4d4cdbf..7dab660 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -88,7 +88,7 @@
 
 /* The values in here are decimal coded as hex as is the case in the NVM map*/
 #define I40E_CURRENT_NVM_VERSION_HI 0x2
-#define I40E_CURRENT_NVM_VERSION_LO 0x1
+#define I40E_CURRENT_NVM_VERSION_LO 0x30
 
 
 /* magic for getting defines into strings */
-- 
1.8.3.1
