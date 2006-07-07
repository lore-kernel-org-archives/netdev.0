From: akpm@osdl.org
Subject: [patch 7/9] 8139cp.c printk fix
Date: Thu, 06 Jul 2006 23:58:26 -0700
Message-ID: <200607070658.k676wQIe030380@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:6594 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751220AbWGGG6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 02:58:32 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

drivers/net/8139cp.c: In function 'cp_init_one':
drivers/net/8139cp.c:1919: warning: format '%lx' expects type 'long unsigned int', but argument 4 has type 'resource_size_t'
drivers/net/8139cp.c:1919: warning: format '%lx' expects type 'long unsigned int', but argument 5 has type 'resource_size_t'


Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/8139cp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/8139cp.c~8139cp-printk-fix drivers/net/8139cp.c
--- a/drivers/net/8139cp.c~8139cp-printk-fix
+++ a/drivers/net/8139cp.c
@@ -1916,7 +1916,7 @@ static int cp_init_one (struct pci_dev *
 	regs = ioremap(pciaddr, CP_REGS_SIZE);
 	if (!regs) {
 		rc = -EIO;
-		dev_err(&pdev->dev, "Cannot map PCI MMIO (%lx@%lx)\n",
+		dev_err(&pdev->dev, "Cannot map PCI MMIO (%Lx@%Lx)\n",
 		       (unsigned long long)pci_resource_len(pdev, 1),
 		       (unsigned long long)pciaddr);
 		goto err_out_res;
_
