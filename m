From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e: trivial: drop duplicate definition
Date: Wed, 17 Feb 2016 09:51:32 -0800
Message-ID: <1455731506-62165-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4789 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161464AbcBQRvt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:51:49 -0500
In-Reply-To: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The probe routine already had a u32 val declared, no need
to do it again.  Found by W=2 compile.

Change-ID: Id7b65f6d0ef6bb71067d0557f5be0202b6d8741e
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 6b158c4..90ad7d7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11008,8 +11008,6 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if ((pf->flags & I40E_FLAG_SRIOV_ENABLED) &&
 	    (pf->flags & I40E_FLAG_MSIX_ENABLED) &&
 	    !test_bit(__I40E_BAD_EEPROM, &pf->state)) {
-		u32 val;
-
 		/* disable link interrupts for VFs */
 		val = rd32(hw, I40E_PFGEN_PORTMDIO_NUM);
 		val &= ~I40E_PFGEN_PORTMDIO_NUM_VFLINK_STAT_ENA_MASK;
-- 
2.5.0
