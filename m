From: Peter Huewe <peterhuewe@gmx.de>
Subject: [PATCH 14/19] net/ethernet/sun/sungem: Use module_pci_driver to register driver
Date: Wed, 22 May 2013 00:58:09 +0200
Message-ID: <1369177096-19674-14-git-send-email-peterhuewe@gmx.de>
References: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Cc: Peter Huewe <peterhuewe@gmx.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Jon Mason <jdmason@kudzu.us>,
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
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
 drivers/net/ethernet/sun/sungem.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index 5f3f9d5..e62df2b 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -3028,15 +3028,4 @@ static struct pci_driver gem_driver = {
 #endif /* CONFIG_PM */
 };
 
-static int __init gem_init(void)
-{
-	return pci_register_driver(&gem_driver);
-}
-
-static void __exit gem_cleanup(void)
-{
-	pci_unregister_driver(&gem_driver);
-}
-
-module_init(gem_init);
-module_exit(gem_cleanup);
+module_pci_driver(gem_driver);
-- 
1.8.1.5
