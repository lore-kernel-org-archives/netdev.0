From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: disable packet split
Date: Thu,  9 Jan 2014 04:52:15 -0800
Message-ID: <1389271944-26227-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49141 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754997AbaAIMwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:52:30 -0500
In-Reply-To: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The driver and hardware support splitting packets on headers
but with the use of GRO we don't need the extra bus
overhead, so make this driver more like igb and ixgbe and
disable packet split.

Change-ID: Id42f2c3736baa9d5bdfe1f72d64226e7d8ebd737
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5cdc67c..beb90e9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5817,7 +5817,6 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	pf->flags = I40E_FLAG_RX_CSUM_ENABLED |
 		    I40E_FLAG_MSI_ENABLED     |
 		    I40E_FLAG_MSIX_ENABLED    |
-		    I40E_FLAG_RX_PS_ENABLED   |
 		    I40E_FLAG_RX_1BUF_ENABLED;
 
 	/* Depending on PF configurations, it is possible that the RSS
-- 
1.8.3.1
