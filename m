From: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>
Subject: [PATCH 2.6.10 2/5] eepro: use module_param macros
Date: Fri, 7 Jan 2005 09:49:39 -0200
Message-ID: <20050107114939.GT27328@cathedrallabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

eepro: use module_param macros

Signed-off-by: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>

diff -uprN -X dontdiff 2.6-inc/drivers/net/eepro.c 2.6/drivers/net/eepro.c
--- 2.6-inc/drivers/net/eepro.c	2005-01-07 09:01:26.128430328 -0200
+++ 2.6/drivers/net/eepro.c	2005-01-07 09:01:12.409515920 -0200
@@ -1732,10 +1732,11 @@ MODULE_AUTHOR("Pascal Dupuis, and aris@c
 MODULE_DESCRIPTION("Intel i82595 ISA EtherExpressPro10/10+ driver");
 MODULE_LICENSE("GPL");
 
-MODULE_PARM(io, "1-" __MODULE_STRING(MAX_EEPRO) "i");
-MODULE_PARM(irq, "1-" __MODULE_STRING(MAX_EEPRO) "i");
-MODULE_PARM(mem, "1-" __MODULE_STRING(MAX_EEPRO) "i");
-MODULE_PARM(autodetect, "1-" __MODULE_STRING(1) "i");
+static int num_params;
+module_param_array(io, int, num_params, 0);
+module_param_array(irq, int, num_params, 0);
+module_param_array(mem, int, num_params, 0);
+module_param(autodetect, int, 0);
 MODULE_PARM_DESC(io, "EtherExpress Pro/10 I/O base addres(es)");
 MODULE_PARM_DESC(irq, "EtherExpress Pro/10 IRQ number(s)");
 MODULE_PARM_DESC(mem, "EtherExpress Pro/10 Rx buffer size(es) in kB (3-29)");
