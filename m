From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 2.6.20-rc1 05/10] if_fddi.h: Add a missing inclusion
Date: Wed, 20 Dec 2006 12:01:55 +0000 (GMT)
Message-ID: <Pine.LNX.4.64N.0612201113410.11005@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-mips@linux-mips.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

 This is a change to include <linux/netdevice.h> in <linux/if_fddi.h> 
which is needed for "struct fddi_statistics".

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---

 Please apply.

  Maciej

patch-mips-2.6.18-20060920-if_fddi-netdev-0
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/include/linux/if_fddi.h linux-mips-2.6.18-20060920/include/linux/if_fddi.h
--- linux-mips-2.6.18-20060920.macro/include/linux/if_fddi.h	2006-09-20 20:51:20.000000000 +0000
+++ linux-mips-2.6.18-20060920/include/linux/if_fddi.h	2006-12-14 04:36:58.000000000 +0000
@@ -103,6 +103,8 @@ struct fddihdr
 	} __attribute__ ((packed));
 
 #ifdef __KERNEL__
+#include <linux/netdevice.h>
+
 /* Define FDDI statistics structure */
 struct fddi_statistics {
 
