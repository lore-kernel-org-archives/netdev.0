From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 080/493] fddi: remove use of __devexit_p
Date: Mon, 19 Nov 2012 13:20:29 -0500
Message-ID: <1353349642-3677-80-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41652 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461Ab2KSSiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:38:00 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: "Maciej W. Rozycki" <macro@linux-mips.org> 
Cc: netdev@vger.kernel.org 
---
 drivers/net/fddi/defxx.c       | 6 +++---
 drivers/net/fddi/skfp/skfddi.c | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index 6695a1d..538f8bb 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -3637,7 +3637,7 @@ static struct pci_driver dfx_pci_driver = {
 	.name		= "defxx",
 	.id_table	= dfx_pci_table,
 	.probe		= dfx_pci_register,
-	.remove		= __devexit_p(dfx_pci_unregister),
+	.remove		= dfx_pci_unregister,
 };
 
 static __devinit int dfx_pci_register(struct pci_dev *pdev,
@@ -3668,7 +3668,7 @@ static struct eisa_driver dfx_eisa_driver = {
 		.name	= "defxx",
 		.bus	= &eisa_bus_type,
 		.probe	= dfx_dev_register,
-		.remove	= __devexit_p(dfx_dev_unregister),
+		.remove	= dfx_dev_unregister,
 	},
 };
 #endif /* CONFIG_EISA */
@@ -3689,7 +3689,7 @@ static struct tc_driver dfx_tc_driver = {
 		.name	= "defxx",
 		.bus	= &tc_bus_type,
 		.probe	= dfx_dev_register,
-		.remove	= __devexit_p(dfx_dev_unregister),
+		.remove	= dfx_dev_unregister,
 	},
 };
 #endif /* CONFIG_TC */
diff --git a/drivers/net/fddi/skfp/skfddi.c b/drivers/net/fddi/skfp/skfddi.c
index 3d9a459..cbabb74 100644
--- a/drivers/net/fddi/skfp/skfddi.c
+++ b/drivers/net/fddi/skfp/skfddi.c
@@ -2243,7 +2243,7 @@ static struct pci_driver skfddi_pci_driver = {
 	.name		= "skfddi",
 	.id_table	= skfddi_pci_tbl,
 	.probe		= skfp_init_one,
-	.remove		= __devexit_p(skfp_remove_one),
+	.remove		= skfp_remove_one,
 };
 
 static int __init skfd_init(void)
-- 
1.8.0
