From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 06/24] drivers/net/irda/donauboe: Convert to module_pci_driver
Date: Mon, 27 May 2013 10:28:43 +0800
Message-ID: <1369621723-31760-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<lizefan@huawei.com>, <libo.chen@huawei.com>,
	<gregkh@linuxfoundation.org>
To: <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:23831 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756009Ab3E0CaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 22:30:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use module_pci_driver instead of init/exit, make code clean.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/irda/donauboe.c |   15 +--------------
 1 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
old mode 100644
new mode 100755
index 510b9c8..c6bfc4a
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -1755,17 +1755,4 @@ static struct pci_driver donauboe_pci_driver = {
 	.resume		= toshoboe_wakeup 
 };
 
-static int __init
-donauboe_init (void)
-{
-  return pci_register_driver(&donauboe_pci_driver);
-}
-
-static void __exit
-donauboe_cleanup (void)
-{
-  pci_unregister_driver(&donauboe_pci_driver);
-}
-
-module_init(donauboe_init);
-module_exit(donauboe_cleanup);
+module_pci_driver(donauboe_pci_driver);
-- 
1.7.1
