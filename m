From: Drew McGowen <quantumdude836@gmail.com>
Subject: [PATCH net-next] natsemi: fix legacy printk() style
Date: Thu, 24 Oct 2013 21:37:26 +0000
Message-ID: <1382650646-24009-1-git-send-email-quantumdude836@gmail.com>
Cc: Drew McGowen <quantumdude836@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f54.google.com ([209.85.213.54]:63607 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754979Ab3JXVhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 17:37:35 -0400
Received: by mail-yh0-f54.google.com with SMTP id b20so1204312yha.13
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 14:37:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed printk() calls to use KERN_* prefix (some were not changed because they
are continuations of a previous line).

Reviewed-by: Sarabeth Jaffe <jaffes2@rpi.edu>
Reviewed-by: Marcio Barbosa <marcio.brito.barbosa@gmail.com>
Reviewed-by: Sean Heyse <heyses@rpi.edu>
Signed-off-by: Drew McGowen <quantumdude836@gmail.com>
---
 drivers/net/ethernet/natsemi/natsemi.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index 7a5e295..cd39d8e 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -814,7 +814,7 @@ static int natsemi_probe1(struct pci_dev *pdev, const struct pci_device_id *ent)
 #ifndef MODULE
 	static int printed_version;
 	if (!printed_version++)
-		printk(version);
+		printk(KERN_INFO version);
 #endif
 
 	i = pci_enable_device(pdev);
@@ -3360,7 +3360,7 @@ static int __init natsemi_init_mod (void)
 {
 /* when a module, this is printed whether or not devices are found in probe */
 #ifdef MODULE
-	printk(version);
+	printk(KERN_INFO version);
 #endif
 
 	return pci_register_driver(&natsemi_driver);
-- 
1.8.1.2
