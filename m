From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH][ATM] iphase: set drvdata before enabling interrupts
Date: Thu, 05 Jun 2008 18:14:04 +0200
Message-ID: <484810CC.7060001@dti2.net>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chas williams <chas@cmf.nrl.navy.mil>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:1392 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755147AbYFEQPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 12:15:21 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v9.6.5)
	with ESMTP id md50013608874.msg
	for <netdev@vger.kernel.org>; Thu, 05 Jun 2008 18:14:09 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
  drivers/atm/iphase.c |    4 ++--
  1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index a51b7cb..92fce28 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -3197,6 +3197,8 @@ static int __devinit ia_init_one(struct pci_dev *pdev,
  	IF_INIT(printk("dev_id = 0x%x iadev->LineRate = %d \n", (u32)dev,
  		iadev->LineRate);)

+	pci_set_drvdata(pdev, dev);
+
  	ia_dev[iadev_count] = iadev;
  	_ia_dev[iadev_count] = dev;
  	iadev_count++;
@@ -3213,8 +3215,6 @@ static int __devinit ia_init_one(struct pci_dev *pdev,
  	iadev->next_board = ia_boards;
  	ia_boards = dev;

-	pci_set_drvdata(pdev, dev);
-
  	return 0;

  err_out_deregister_dev:
-- 

