From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] wan: pci200syn needs capability.h
Date: Tue, 13 Oct 2009 10:00:16 -0700
Message-ID: <20091013100016.3c9bfad7.randy.dunlap@oracle.com>
References: <20091013162312.8b93998b.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, davem@davemloft.net,
	Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091013162312.8b93998b.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Driver is missing header file capability.h:

drivers/net/wan/pci200syn.c:212: error: implicit declaration of function 'capable'
drivers/net/wan/pci200syn.c:212: error: 'CAP_NET_ADMIN' undeclared (first use in this function)

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/wan/pci200syn.c |    1 +
 1 file changed, 1 insertion(+)

--- linux-next-20091012.orig/drivers/net/wan/pci200syn.c
+++ linux-next-20091012/drivers/net/wan/pci200syn.c
@@ -18,6 +18,7 @@
 #include <linux/kernel.h>
 #include <linux/slab.h>
 #include <linux/types.h>
+#include <linux/capability.h>
 #include <linux/fcntl.h>
 #include <linux/in.h>
 #include <linux/string.h>
