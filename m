From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] eepro init section usage
Date: Sun, 7 Mar 2004 19:35:42 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040307193542.20a510c9.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

eepro_print_info() can be __init.

Please apply.  Patch is to 2.6.4-rc2.

--
~Randy



diffstat:=
 drivers/net/eepro.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)


diff -Naurp ./drivers/net/eepro.c~eepro_init ./drivers/net/eepro.c
--- ./drivers/net/eepro.c~eepro_init	2004-02-17 19:58:50.000000000 -0800
+++ ./drivers/net/eepro.c	2004-03-07 16:36:03.000000000 -0800
@@ -680,7 +680,7 @@ static void eepro_recalc (struct net_dev
 }
 
 /* prints boot-time info */
-static void eepro_print_info (struct net_device *dev)
+static void __init eepro_print_info (struct net_device *dev)
 {
 	struct eepro_local *	lp = dev->priv;
 	int			i;
