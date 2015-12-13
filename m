From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 05/11] i40e: use explicit cast from u16 to u8
Date: Sat, 12 Dec 2015 21:17:31 -0800
Message-ID: <1449983857-74434-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449983857-74434-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kamil Krawczyk <kamil.krawczyk@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56992 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750909AbbLMFRl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 00:17:41 -0500
In-Reply-To: <1449983857-74434-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamil Krawczyk <kamil.krawczyk@intel.com>

Current implementation generates compilation warnings.

Change-ID: Icceefb50fe62aefaf90a64afb7192e08355a4ec5
Signed-off-by: Kamil Krawczyk <kamil.krawczyk@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
index 79ae7be..daa9204 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
@@ -762,7 +762,7 @@ static void i40e_write_byte(u8 *hmc_bits,
 
 	/* prepare the bits and mask */
 	shift_width = ce_info->lsb % 8;
-	mask = BIT(ce_info->width) - 1;
+	mask = (u8)(BIT(ce_info->width) - 1);
 
 	src_byte = *from;
 	src_byte &= mask;
-- 
2.5.0
