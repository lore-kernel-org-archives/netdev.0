From: Randy Dunlap <randy.dunlap@Oracle.COM>
Subject: [PATCH -next] can: softing_cs needs slab.h
Date: Wed, 9 Feb 2011 08:44:56 -0800
Message-ID: <20110209084456.802370fa.randy.dunlap@oracle.com>
References: <20110209170225.94eae681.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	davem@davemloft.net, socketcan-core@lists.berlios.de
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:24731 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105Ab1BIQpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 11:45:17 -0500
In-Reply-To: <20110209170225.94eae681.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

softing_cs.c uses kzalloc & kfree, so it needs to include linux/slab.h.

drivers/net/can/softing/softing_cs.c:234: error: implicit declaration of function 'kfree'
drivers/net/can/softing/softing_cs.c:271: error: implicit declaration of function 'kzalloc'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/can/softing/softing_cs.c |    1 +
 1 file changed, 1 insertion(+)

--- linux-next-20110209.orig/drivers/net/can/softing/softing_cs.c
+++ linux-next-20110209/drivers/net/can/softing/softing_cs.c
@@ -19,6 +19,7 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
+#include <linux/slab.h>
 
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
