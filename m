From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] qed: Remove a stray tab
Date: Tue, 17 May 2016 10:34:50 +0300
Message-ID: <20160517073450.GE10872@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ariel Elior <Ariel.Elior@qlogic.com>, everest-linux-l2@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25386 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791AbcEQHfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 03:35:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This line was intended more than it should be.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 6ffc21d..05fcb25 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -177,7 +177,7 @@ static int qed_init_pci(struct qed_dev *cdev,
 	}
 
 	if (IS_PF(cdev)) {
-			cdev->db_phys_addr = pci_resource_start(cdev->pdev, 2);
+		cdev->db_phys_addr = pci_resource_start(cdev->pdev, 2);
 		cdev->db_size = pci_resource_len(cdev->pdev, 2);
 		cdev->doorbells = ioremap_wc(cdev->db_phys_addr, cdev->db_size);
 		if (!cdev->doorbells) {
