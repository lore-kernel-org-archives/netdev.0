From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next] i40e: mark constant as ULL
Date: Wed,  4 Feb 2015 12:41:04 +0100
Message-ID: <1423050064-25087-1-git-send-email-sassmann@kpanic.de>
Cc: davem@davemloft.net, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54339 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753406AbbBDLmM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 06:42:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This avoids a compile error on 32bit.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
index 4627588..f221ace 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
@@ -908,7 +908,7 @@ static void i40e_write_qword(u8 *hmc_bits,
 	if (ce_info->width < 64)
 		mask = ((u64)1 << ce_info->width) - 1;
 	else
-		mask = 0xFFFFFFFFFFFFFFFF;
+		mask = 0xFFFFFFFFFFFFFFFFULL;
 
 	/* don't swizzle the bits until after the mask because the mask bits
 	 * will be in a different bit position on big endian machines
-- 
2.1.0
