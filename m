From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] pch_gbe: add header files
Date: Tue, 28 Sep 2010 09:56:43 -0700
Message-ID: <20100928095643.18c5020f.randy.dunlap@oracle.com>
References: <20100928141823.8c61000e.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	<masa-korg@dsn.okisemi.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, davem@davemloft.net
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100928141823.8c61000e.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix build errors, more header files needed.

drivers/net/pch_gbe/pch_gbe_main.c:965: error: implicit declaration of function 'tcp_hdr'
drivers/net/pch_gbe/pch_gbe_main.c:965: error: invalid type argument of '->' (have 'int')
drivers/net/pch_gbe/pch_gbe_main.c:968: error: invalid type argument of '->' (have 'int')
drivers/net/pch_gbe/pch_gbe_main.c:976: error: implicit declaration of function 'udp_hdr'
drivers/net/pch_gbe/pch_gbe_main.c:976: error: invalid type argument of '->' (have 'int')
drivers/net/pch_gbe/pch_gbe_main.c:980: error: invalid type argument of '->' (have 'int')

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/pch_gbe/pch_gbe.h |    2 ++
 1 file changed, 2 insertions(+)

--- linux-next-20100927.orig/drivers/net/pch_gbe/pch_gbe.h
+++ linux-next-20100927/drivers/net/pch_gbe/pch_gbe.h
@@ -31,6 +31,8 @@
 #include <linux/ethtool.h>
 #include <linux/vmalloc.h>
 #include <net/ip.h>
+#include <net/tcp.h>
+#include <net/udp.h>
 
 /**
  * pch_gbe_regs_mac_adr - Structure holding values of mac address registers
