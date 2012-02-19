From: Nikola Pajkovsky <n.pajkovsky@gmail.com>
Subject: [PATCH] b44: remove __exit from b44_pci_exit()
Date: Sun, 19 Feb 2012 21:47:43 +0100
Message-ID: <74eccdc061524ad9ab6aae1ca0dd7a020921b1fe.1329684207.git.n.pajkovsky@gmail.com>
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Nikola Pajkovsky <n.pajkovsky@gmail.com>
To: Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:55944 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754924Ab2BSUqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2012 15:46:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WARNING: drivers/net/ethernet/broadcom/built-in.o(.init.text+0x5d): Section mismatch in reference from the function b44_init() to the function .exit.text:b44_pci_exit()

module exits with b44_cleanup()

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
