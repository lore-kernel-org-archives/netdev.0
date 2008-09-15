From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -mm] hp-plus: fix build error
Date: Mon, 15 Sep 2008 12:16:01 -0700
Message-ID: <20080915121601.416f5f78.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>, akpm <akpm@linux-foundation.org>,
	alan@lxorguk.ukuu.org.uk
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:52126 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753499AbYIOTQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 15:16:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix hp-plus build error (yet again; will it ever end?):

hp-plus.c:(.init.text+0xa2cd): undefined reference to `NS8390p_init'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/hp-plus.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.27-rc5-mm1.orig/drivers/net/hp-plus.c
+++ linux-2.6.27-rc5-mm1/drivers/net/hp-plus.c
@@ -262,7 +262,7 @@ static int __init hpp_probe1(struct net_
 	}
 
 	outw(Perf_Page, ioaddr + HP_PAGING);
-	NS8390p_init(dev, 0);
+	NS8390_init(dev, 0);
 	/* Leave the 8390 and HP chip reset. */
 	outw(inw(ioaddr + HPP_OPTION) & ~EnableIRQ, ioaddr + HPP_OPTION);
 
