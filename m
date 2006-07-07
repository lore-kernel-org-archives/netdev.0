From: akpm@osdl.org
Subject: [patch 1/9] e1000: irq naming update
Date: Thu, 06 Jul 2006 23:58:19 -0700
Message-ID: <200607070658.k676wJcD030362@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:194 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751216AbWGGG6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 02:58:25 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

Use the new names.

Cc: Auke Kok <auke-jan.h.kok@intel.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/e1000/e1000_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/e1000/e1000_main.c~e1000-irq-naming-update drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c~e1000-irq-naming-update
+++ a/drivers/net/e1000/e1000_main.c
@@ -283,7 +283,7 @@ static int e1000_request_irq(struct e100
 		}
 	}
 	if (adapter->have_msi)
-		flags &= ~SA_SHIRQ;
+		flags &= ~IRQF_SHARED;
 #endif
 	if ((err = request_irq(adapter->pdev->irq, &e1000_intr, flags,
 	                       netdev->name, netdev)))
_
