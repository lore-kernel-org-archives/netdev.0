From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 081/493] hippi: remove use of __devexit_p
Date: Mon, 19 Nov 2012 13:20:30 -0500
Message-ID: <1353349642-3677-81-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Jes Sorensen <jes@trained-monkey.org>, linux-hippi@sunsite.dk,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41651 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754493Ab2KSSiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:38:04 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Jes Sorensen <jes@trained-monkey.org> 
Cc: linux-hippi@sunsite.dk 
Cc: netdev@vger.kernel.org 
---
 drivers/net/hippi/rrunner.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index d471963..4802b46 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -1681,7 +1681,7 @@ static struct pci_driver rr_driver = {
 	.name		= "rrunner",
 	.id_table	= rr_pci_tbl,
 	.probe		= rr_init_one,
-	.remove		= __devexit_p(rr_remove_one),
+	.remove		= rr_remove_one,
 };
 
 static int __init rr_init_module(void)
-- 
1.8.0
