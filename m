From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/17] e1000e: clean up the local variable
Date: Sun, 13 Dec 2015 00:31:22 -0800
Message-ID: <1449995490-17020-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:35752 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751448AbbLMIlC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 03:41:02 -0500
In-Reply-To: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

The local variable 'ret' doesn't serve much purpose so we might as well
clean it up.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 0a854a4..0003bf6 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -7504,14 +7504,11 @@ static struct pci_driver e1000_driver = {
  **/
 static int __init e1000_init_module(void)
 {
-	int ret;
-
 	pr_info("Intel(R) PRO/1000 Network Driver - %s\n",
 		e1000e_driver_version);
 	pr_info("Copyright(c) 1999 - 2015 Intel Corporation.\n");
-	ret = pci_register_driver(&e1000_driver);
 
-	return ret;
+	return pci_register_driver(&e1000_driver);
 }
 module_init(e1000_init_module);
 
-- 
2.5.0
