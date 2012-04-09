From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH 06/26] bna: remove redundant NULL test before
 release_firmware()
Date: Mon, 9 Apr 2012 22:50:24 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1204092210470.13925@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trivial@kernel.org, netdev@vger.kernel.org,
	Rasesh Mody <rmody@brocade.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

release_firmware() does its own NULL test so explicit test before call
is unneeded.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/ethernet/brocade/bna/bnad.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index ff78f77..d86390c 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3546,9 +3546,7 @@ static void __exit
 bnad_module_exit(void)
 {
 	pci_unregister_driver(&bnad_pci_driver);
-
-	if (bfi_fw)
-		release_firmware(bfi_fw);
+	release_firmware(bfi_fw);
 }
 
 module_init(bnad_module_init);
-- 
1.7.10


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
