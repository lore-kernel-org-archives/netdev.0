From: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>
Subject: [PATCH 2.6.10 4/5] eepro: fix return value in init_module()
Date: Fri, 7 Jan 2005 09:52:20 -0200
Message-ID: <20050107115220.GV27328@cathedrallabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

eepro: fix return value in init_module()

Signed-off-by: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>

--- 2.6/drivers/net/eepro.c.orig	2004-10-05 22:26:48.000000000 -0300
+++ 2.6/drivers/net/eepro.c	2004-10-05 22:27:00.000000000 -0300
@@ -1811,7 +1811,7 @@ init_module(void)
 	if (io[0] == 0 && autodetect == 0) {
 		printk(KERN_WARNING "eepro_init_module: Probe is very dangerous in ISA boards!\n");
 		printk(KERN_WARNING "eepro_init_module: Please add \"autodetect=1\" to force probe\n");
-		return 1;
+		return -ENODEV;
 	}
 	else if (autodetect) {
 		/* if autodetect is set then we must force detection */
