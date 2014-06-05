From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] i40evf: set descriptor multiple to 32
Date: Thu,  5 Jun 2014 00:49:20 -0700
Message-ID: <1401954567-13557-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401954567-13557-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:52029 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751884AbaFEHtm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 03:49:42 -0400
In-Reply-To: <1401954567-13557-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Hardware requires descriptors to be allocated in groups of 32.

Change-ID: I752ccc96769d1bd8d3018c004b8aeff464045bf2
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 2913bc3..bfd8542 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -80,7 +80,7 @@ struct i40e_vsi {
 #define I40EVF_MIN_TXD       64
 #define I40EVF_MAX_RXD       4096
 #define I40EVF_MIN_RXD       64
-#define I40EVF_REQ_DESCRIPTOR_MULTIPLE  8
+#define I40EVF_REQ_DESCRIPTOR_MULTIPLE  32
 
 /* Supported Rx Buffer Sizes */
 #define I40EVF_RXBUFFER_64    64     /* Used for packet split */
-- 
1.9.3
