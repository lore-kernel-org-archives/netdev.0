From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] farsync needs <asm/io.h>
Date: Mon, 31 May 2004 11:12:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040531091208.GA13982@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

i386 gets it implicitly from somewhere but some architectures don't.
Also move <asm/uaccess.h> down so we have asm after linux headers.


--- 1.20/drivers/net/wan/farsync.c	2004-05-27 19:24:11 +02:00
+++ edited/drivers/net/wan/farsync.c	2004-05-30 10:06:12 +02:00
@@ -21,9 +21,10 @@
 #include <linux/pci.h>
 #include <linux/ioport.h>
 #include <linux/init.h>
-#include <asm/uaccess.h>
 #include <linux/if.h>
 #include <linux/hdlc.h>
+#include <asm/io.h>
+#include <asm/uaccess.h>
 
 #include "farsync.h"
 
