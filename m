From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] ibmtr init section usage
Date: Sun, 7 Mar 2004 19:38:03 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040307193803.576182ce.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


probe functions can be __devinit.

Patch is to 2.6.4-rc2.  Please apply.

--
~Randy


diffstat:=
 drivers/net/tokenring/ibmtr.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff -Naurp ./drivers/net/tokenring/ibmtr.c~ibmtr_init ./drivers/net/tokenring/ibmtr.c
--- ./drivers/net/tokenring/ibmtr.c~ibmtr_init	2004-03-06 20:57:06.000000000 -0800
+++ ./drivers/net/tokenring/ibmtr.c	2004-03-07 18:31:11.000000000 -0800
@@ -333,7 +333,7 @@ static void ibmtr_cleanup_card(struct ne
 #endif		
 }
 
-int ibmtr_probe_card(struct net_device *dev)
+int __devinit ibmtr_probe_card(struct net_device *dev)
 {
 	int err = ibmtr_probe(dev);
 	if (!err) {
@@ -356,7 +356,7 @@ int ibmtr_probe_card(struct net_device *
  *	which references it.
  ****************************************************************************/
 
-static int ibmtr_probe(struct net_device *dev)
+static int __devinit ibmtr_probe(struct net_device *dev)
 {
 	int i;
 	int base_addr = dev->base_addr;
