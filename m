From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] pcnet32: fix user visible typo
Date: Tue, 29 Aug 2006 03:32:49 +0400
Message-ID: <20060828233248.GA5193@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tsbogend@alpha.franken.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:12840 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964899AbWH1Xdb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 19:33:31 -0400
Received: by nf-out-0910.google.com with SMTP id o25so77236nfa
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 16:33:27 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also, final dot removed and single form fixed. The cause of #6428 is
still to be found.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/pcnet32.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -2986,7 +2986,8 @@ static int __init pcnet32_init_module(vo
 		pcnet32_probe_vlbus(pcnet32_portlist);
 
 	if (cards_found && (pcnet32_debug & NETIF_MSG_PROBE))
-		printk(KERN_INFO PFX "%d cards_found.\n", cards_found);
+		printk(KERN_INFO PFX "%d card%s found\n",
+			cards_found, cards_found > 1 ? "s" : "");
 
 	return (pcnet32_have_pci + cards_found) ? 0 : -ENODEV;
 }

