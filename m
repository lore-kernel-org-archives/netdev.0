From: Peter Huewe <peterhuewe@gmx.de>
Subject: [PATCH 13/19] net/ethernet/qlogic/qlge/qlge_main: Use module_pci_driver to register driver
Date: Wed, 22 May 2013 00:58:08 +0200
Message-ID: <1369177096-19674-13-git-send-email-peterhuewe@gmx.de>
References: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Cc: Peter Huewe <peterhuewe@gmx.de>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>,
	linux-driver@qlogic.com (supporter:QLOGIC QLGE 10Gb...),
	netdev@vger.kernel.org (open list:QLOGIC QLGE 10Gb...),
	linux-kernel@vger.kernel.org (open list)
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing some boilerplate by using module_pci_driver instead of calling
register and unregister in the otherwise empty init/exit functions.

Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 50235d2..e04d471 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -4945,15 +4945,4 @@ static struct pci_driver qlge_driver = {
 	.err_handler = &qlge_err_handler
 };
 
-static int __init qlge_init_module(void)
-{
-	return pci_register_driver(&qlge_driver);
-}
-
-static void __exit qlge_exit(void)
-{
-	pci_unregister_driver(&qlge_driver);
-}
-
-module_init(qlge_init_module);
-module_exit(qlge_exit);
+module_pci_driver(qlge_driver);
-- 
1.8.1.5
