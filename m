From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] hp-plus: fix link objects
Date: Tue, 2 Sep 2008 13:03:44 -0700
Message-ID: <20080902130344.d8847b3d.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, akpm <akpm@linux-foundation.org>,
	jgarzik <jgarzik@pobox.com>, alan@lxorguk.ukuu.org.uk
To: linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix hp-plus Makefile object file:

drivers/built-in.o: In function `hpp_open':
hp-plus.c:(.text+0xaf445): undefined reference to `ei_interrupt'
hp-plus.c:(.text+0xaf4ac): undefined reference to `ei_open'
drivers/built-in.o: In function `hpp_close':
hp-plus.c:(.text+0xaf59d): undefined reference to `ei_close'
drivers/built-in.o: In function `hpp_probe1':
hp-plus.c:(.init.text+0x7314): undefined reference to `ei_poll'
drivers/built-in.o: In function `hp_plus_probe':
(.init.text+0x7407): undefined reference to `__alloc_ei_netdev'
make[1]: *** [.tmp_vmlinux1] Error 1

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/Makefile |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20080902.orig/drivers/net/Makefile
+++ linux-next-20080902/drivers/net/Makefile
@@ -111,7 +111,7 @@ obj-$(CONFIG_EL2) += 3c503.o 8390p.o
 obj-$(CONFIG_NE2000) += ne.o 8390p.o
 obj-$(CONFIG_NE2_MCA) += ne2.o 8390p.o
 obj-$(CONFIG_HPLAN) += hp.o 8390p.o
-obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390p.o
+obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390.o
 obj-$(CONFIG_ULTRA) += smc-ultra.o 8390.o
 obj-$(CONFIG_ULTRAMCA) += smc-mca.o 8390.o
 obj-$(CONFIG_ULTRA32) += smc-ultra32.o 8390.o
