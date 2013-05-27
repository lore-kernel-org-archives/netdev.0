From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 08/24] drivers/atm/he: Convert to module_pci_driver
Date: Mon, 27 May 2013 10:28:50 +0800
Message-ID: <1369621730-6348-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<lizefan@huawei.com>, <libo.chen@huawei.com>,
	<gregkh@linuxfoundation.org>
To: <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use module_pci_driver instead of init/exit, make code clean.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/atm/he.c |   13 +------------
 1 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 507362a..80f9743 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -2872,15 +2872,4 @@ static struct pci_driver he_driver = {
 	.id_table =	he_pci_tbl,
 };
 
-static int __init he_init(void)
-{
-	return pci_register_driver(&he_driver);
-}
-
-static void __exit he_cleanup(void)
-{
-	pci_unregister_driver(&he_driver);
-}
-
-module_init(he_init);
-module_exit(he_cleanup);
+module_pci_driver(he_driver);
-- 
1.7.1
