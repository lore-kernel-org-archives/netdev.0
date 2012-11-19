From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 078/493] arcnet: remove use of __devexit_p
Date: Mon, 19 Nov 2012 13:20:27 -0500
Message-ID: <1353349642-3677-78-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41652 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461Ab2KSSiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:38:07 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: netdev@vger.kernel.org 
---
 drivers/net/arcnet/com20020-pci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index d427493..dcedba8 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -178,7 +178,7 @@ static struct pci_driver com20020pci_driver = {
 	.name		= "com20020",
 	.id_table	= com20020pci_id_table,
 	.probe		= com20020pci_probe,
-	.remove		= __devexit_p(com20020pci_remove),
+	.remove		= com20020pci_remove,
 };
 
 static int __init com20020pci_init(void)
-- 
1.8.0
