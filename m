From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 10/20] uli526x: fix misspelling of current function in string
Date: Sun,  7 Dec 2014 20:20:52 +0100
Message-ID: <1417980062-25151-11-git-send-email-Julia.Lawall@lip6.fr>
References: <1417980062-25151-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux@rasmusvillemoes.dk,
	joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417980062-25151-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace a misspelled function name by %s and then __func__.

This was done using Coccinelle, including the use of Levenshtein distance,
as proposed by Rasmus Villemoes.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
The semantic patch is difficult to summarize, but is available in the cover
letter of this patch series.

 drivers/net/ethernet/dec/tulip/uli526x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index 4061f9b..1c5916b 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -1837,7 +1837,7 @@ static int __init uli526x_init_module(void)
 
 static void __exit uli526x_cleanup_module(void)
 {
-	ULI526X_DBUG(0, "uli526x_clean_module() ", debug);
+	ULI526X_DBUG(0, "uli526x_cleanup_module() ", debug);
 	pci_unregister_driver(&uli526x_driver);
 }
 
