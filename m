From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH 2/2 -next] niu: always include of_device.h
Date: Wed, 9 Jun 2010 15:44:09 -0700
Message-ID: <20100609154409.bf024c0c.randy.dunlap@oracle.com>
References: <20100609133443.38f1f957.sfr@canb.auug.org.au>
	<20100609103657.66252a27.randy.dunlap@oracle.com>
	<20100609.110638.112605100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100609.110638.112605100.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

The niu driver uses struct of_device when built on any arch, not
only SPARC64, so always #include <linux/of_device.h>.

drivers/net/niu.c:9700: warning: 'struct of_device' declared inside parameter list
drivers/net/niu.c:9700: warning: its scope is only this definition or declaration, which is probably not what you want
drivers/net/niu.c:9716: warning: assignment from incompatible pointer type

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc:	Grant Likely <grant.likely@secretlab.ca>
Cc:	Dave Miller <davem@davemloft.net>
---
 drivers/net/niu.c |    3 ---
 1 file changed, 3 deletions(-)

--- linux-next-20100609.orig/drivers/net/niu.c
+++ linux-next-20100609/drivers/net/niu.c
@@ -28,10 +28,7 @@
 #include <linux/slab.h>
 
 #include <linux/io.h>
-
-#ifdef CONFIG_SPARC64
 #include <linux/of_device.h>
-#endif
 
 #include "niu.h"
 
