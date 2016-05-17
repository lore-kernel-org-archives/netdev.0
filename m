From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2] qed: Remove a stray tab
Date: Tue, 17 May 2016 11:09:20 +0300
Message-ID: <20160517080920.GD11011@mwanda>
References: <CO2PR11MB00880C22B76A203A30BCDF8297480@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ariel Elior <Ariel.Elior@qlogic.com>, everest-linux-l2@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:21393 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbcEQIJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 04:09:39 -0400
Content-Disposition: inline
In-Reply-To: <CO2PR11MB00880C22B76A203A30BCDF8297480@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This line was indented more than it should be.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
v2: fix a typo

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
