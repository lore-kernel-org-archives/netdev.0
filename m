From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 13/16] i40e: increase ARQ size
Date: Sat,  6 Dec 2014 05:02:10 -0800
Message-ID: <1417870933-17248-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8818 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752683AbaLFNDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Dec 2014 08:03:00 -0500
In-Reply-To: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The ARQ needs to have at least as many entries as VFs, or the VFs will
get errors from the FW when they send messages to the PF. Since we don't
know how many VFs we'll end up with, just set up 128 descriptors.

Change-ID: I04ae3d1c7faf09110eb782214e9c05aeb62a6c59
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 464342a..fc50f64 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -87,7 +87,7 @@
 #define I40E_MINIMUM_FCOE             1 /* minimum number of QPs for FCoE */
 #endif /* I40E_FCOE */
 #define I40E_MAX_AQ_BUF_SIZE          4096
-#define I40E_AQ_LEN                   32
+#define I40E_AQ_LEN                   128
 #define I40E_AQ_WORK_LIMIT            16
 #define I40E_MAX_USER_PRIORITY        8
 #define I40E_DEFAULT_MSG_ENABLE       4
-- 
1.9.3
