From: Cong Ding <dinggnu@gmail.com>
Subject: [PATCH] atm: fore200e.c: fix uninitialized variable
Date: Mon, 14 Jan 2013 18:57:43 +0000
Message-ID: <1358189864-28735-1-git-send-email-dinggnu@gmail.com>
Cc: Cong Ding <dinggnu@gmail.com>
To: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:58870 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756094Ab3ANS5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 13:57:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the variable err is uninitialized if all the macros in the function are
disabled.

Signed-off-by: Cong Ding <dinggnu@gmail.com>
---
 drivers/atm/fore200e.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index 204814e..d4725fc 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -2780,7 +2780,7 @@ static struct pci_driver fore200e_pca_driver = {
 
 static int __init fore200e_module_init(void)
 {
-	int err;
+	int err = 0;
 
 	printk(FORE200E "FORE Systems 200E-series ATM driver - version " FORE200E_VERSION "\n");
 
-- 
1.7.9.5
