From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] smctr: fix init section usage
Date: Sun, 7 Mar 2004 19:40:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040307194009.4ce2f9b1.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

smctr_chk_mca() can be __init.

Patch is to 2.6.4-rc2.  Please apply.

--
~Randy


diffstat:=
 drivers/net/tokenring/smctr.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)


diff -Naurp ./drivers/net/tokenring/smctr.c~smctr_init ./drivers/net/tokenring/smctr.c
--- ./drivers/net/tokenring/smctr.c~smctr_init	2004-02-17 19:57:56.000000000 -0800
+++ ./drivers/net/tokenring/smctr.c	2004-03-07 17:39:14.000000000 -0800
@@ -477,7 +477,7 @@ static int smctr_checksum_firmware(struc
         return (0);
 }
 
-static int smctr_chk_mca(struct net_device *dev)
+static int __init smctr_chk_mca(struct net_device *dev)
 {
 #ifdef CONFIG_MCA
 	struct net_local *tp = (struct net_local *)dev->priv;
