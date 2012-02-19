From: Nikola Pajkovsky <npajkovs@redhat.com>
Subject: [PATCH] b44: fix section mismatch warnings in b44.c
Date: Sun, 19 Feb 2012 15:45:54 +0100
Message-ID: <c8f624fdb13dcf32d82b1abb70a423abc4a2359a.1329662367.git.n.pajkovsky@gmail.com>
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Nikola Pajkovsky <n.pajkovsky@gmail.com>
To: Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54565 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753770Ab2BSOov (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Feb 2012 09:44:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikola Pajkovsky <n.pajkovsky@gmail.com>

Signed-off-by: Nikola Pajkovsky <n.pajkovsky@gmail.com>
---
 drivers/net/ethernet/broadcom/b44.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 66f53c7..46b8b7d8 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2338,7 +2338,7 @@ static inline int __init b44_pci_init(void)
 	return err;
 }
 
-static inline void __exit b44_pci_exit(void)
+static inline void b44_pci_exit(void)
 {
 #ifdef CONFIG_B44_PCI
 	ssb_pcihost_unregister(&b44_pci_driver);
-- 
1.7.9.1.244.gb0d66b
