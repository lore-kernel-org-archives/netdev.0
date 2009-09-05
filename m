From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] net: fix hydra printk format warning
Date: Fri, 4 Sep 2009 17:20:37 -0700
Message-ID: <20090904172037.b2dd7f20.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Roman Zippel <zippel@linux-m68k.org>, davem@davemloft.net
To: linux-m68k@vger.kernel.org, netdev <netdev@vger.kernel.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

m68k:
drivers/net/hydra.c:178: warning: format '%08lx' expects type 'long unsigned int', but argument 3 has type 'resource_size_t'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/hydra.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.31-rc8-git1.orig/drivers/net/hydra.c
+++ linux-2.6.31-rc8-git1/drivers/net/hydra.c
@@ -173,9 +173,9 @@ static int __devinit hydra_init(struct z
 
     zorro_set_drvdata(z, dev);
 
-    printk(KERN_INFO "%s: Hydra at 0x%08lx, address "
+    printk(KERN_INFO "%s: Hydra at 0x%08llx, address "
 	   "%pM (hydra.c " HYDRA_VERSION ")\n",
-	   dev->name, z->resource.start, dev->dev_addr);
+	   dev->name, (unsigned long long)z->resource.start, dev->dev_addr);
 
     return 0;
 }




---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
