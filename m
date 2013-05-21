From: Peter Huewe <peterhuewe@gmx.de>
Subject: [PATCH 15/19] net/ethernet/amd/amd8111e: Use module_pci_driver to register driver
Date: Wed, 22 May 2013 00:58:10 +0200
Message-ID: <1369177096-19674-15-git-send-email-peterhuewe@gmx.de>
References: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Cc: Peter Huewe <peterhuewe@gmx.de>, Patrick McHardy <kaber@trash.net>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
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
 drivers/net/ethernet/amd/amd8111e.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 8e6b665..bc71aec 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -1981,15 +1981,4 @@ static struct pci_driver amd8111e_driver = {
 	.resume		= amd8111e_resume
 };
 
-static int __init amd8111e_init(void)
-{
-	return pci_register_driver(&amd8111e_driver);
-}
-
-static void __exit amd8111e_cleanup(void)
-{
-	pci_unregister_driver(&amd8111e_driver);
-}
-
-module_init(amd8111e_init);
-module_exit(amd8111e_cleanup);
+module_pci_driver(amd8111e_driver);
-- 
1.8.1.5
