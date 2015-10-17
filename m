From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/17] i40e: declare rather than initialize int object
Date: Fri, 16 Oct 2015 22:28:30 -0700
Message-ID: <1445059711-45992-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49921 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752473AbbJQF2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 01:28:43 -0400
In-Reply-To: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

'err' would be overwritten immediately, so we should declare it only
rather than initialize it to zero.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 54af6d6..92b9d27 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10179,7 +10179,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	static u16 pfs_found;
 	u16 wol_nvm_bits;
 	u16 link_status;
-	int err = 0;
+	int err;
 	u32 len;
 	u32 i;
 
-- 
2.4.3
