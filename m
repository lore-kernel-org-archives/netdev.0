From: Pramod Gurav <pramod.gurav@smartplayin.com>
Subject: [PATCH] ssb: Fix Sparse error in main
Date: Wed,  1 Oct 2014 12:36:36 +0530
Message-ID: <1412147196-7466-1-git-send-email-pramod.gurav@smartplayin.com>
Cc: Pramod Gurav <pramod.gurav@smartplayin.com>,
	Michael Buesch <m@bues.ch>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change fixes below sparse error:

drivers/ssb/main.c:94:16: warning: symbol 'ssb_sdio_func_to_bus'
was not declared. Should it be static?

Cc: Michael Buesch <m@bues.ch>
Cc: netdev@vger.kernel.org
Signed-off-by: Pramod Gurav <pramod.gurav@smartplayin.com>
---
 drivers/ssb/ssb_private.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/ssb/ssb_private.h b/drivers/ssb/ssb_private.h
index eb507a5..86bbbe3 100644
--- a/drivers/ssb/ssb_private.h
+++ b/drivers/ssb/ssb_private.h
@@ -193,6 +193,7 @@ extern struct ssb_bus *ssb_pci_dev_to_bus(struct pci_dev *pdev);
 int ssb_for_each_bus_call(unsigned long data,
 			  int (*func)(struct ssb_bus *bus, unsigned long data));
 extern struct ssb_bus *ssb_pcmcia_dev_to_bus(struct pcmcia_device *pdev);
+struct ssb_bus *ssb_sdio_func_to_bus(struct sdio_func *func);
 
 struct ssb_freeze_context {
 	/* Pointer to the bus */
-- 
1.7.9.5
