From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 01/10] sky2: fix sparse warning
Date: Fri, 12 Feb 2010 08:57:58 -0800
Message-ID: <20100212165937.579717088@vyatta.com>
References: <20100212165757.767062851@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49484 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757320Ab0BLRHo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 12:07:44 -0500
Content-Disposition: inline; filename=sky2-sparse-warn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Warning about hidden variable

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2010-02-11 09:15:11.429362380 -0800
+++ b/drivers/net/sky2.c	2010-02-11 09:15:20.407488037 -0800
@@ -3128,7 +3128,7 @@ static void sky2_reset(struct sky2_hw *h
 		/* check if PSMv2 was running before */
 		reg = sky2_pci_read16(hw, PSM_CONFIG_REG3);
 		if (reg & PCI_EXP_LNKCTL_ASPMC) {
-			int cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
+			cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
 			/* restore the PCIe Link Control register */
 			sky2_pci_write16(hw, cap + PCI_EXP_LNKCTL, reg);
 		}

-- 

