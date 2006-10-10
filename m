From: akpm@osdl.org
Subject: [patch 6/7] pci_module_init() convertion in olympic.c
Date: Tue, 10 Oct 2006 14:33:29 -0700
Message-ID: <200610102133.k9ALXT9n024977@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, henne@nachtwindheim.de,
	alan@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:56985 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030448AbWJJVdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2006 17:33:43 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Henrik Kretzschmar <henne@nachtwindheim.de>

pci_module_init() convertion in olympic.c

Signed-off-by: Henrik Kretzschmar <henne@nachtwindheim.de>
Acked-by: Alan Cox <alan@redhat.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/tokenring/olympic.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/tokenring/olympic.c~pci_module_init-convertion-in-olympicc drivers/net/tokenring/olympic.c
--- a/drivers/net/tokenring/olympic.c~pci_module_init-convertion-in-olympicc
+++ a/drivers/net/tokenring/olympic.c
@@ -1771,7 +1771,7 @@ static struct pci_driver olympic_driver 
 
 static int __init olympic_pci_init(void) 
 {
-	return pci_module_init (&olympic_driver) ; 
+	return pci_register_driver(&olympic_driver) ;
 }
 
 static void __exit olympic_pci_cleanup(void)
_
