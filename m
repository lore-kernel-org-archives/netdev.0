From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 2/10] hostap: Include asm/io.h
Date: Sat, 12 Mar 2005 16:29:40 -0800
Message-ID: <20050313002940.GC8253@jm.kir.nu>
References: <20050313001706.GA8253@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050313001706.GA8253@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Include asm/io.h into hostap_{pci,plx}.c since this seems to be needed
for ARM on Linux 2.6.x and this file is already included into
hostap_cs.c anyway.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_pci.c
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_pci.c	2005-03-12 16:10:40.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_pci.c	2005-03-12 16:10:50.000000000 -0800
@@ -17,6 +17,7 @@
 
 #include <linux/ioport.h>
 #include <linux/pci.h>
+#include <asm/io.h>
 
 #include "hostap_wlan.h"
 
Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_plx.c
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_plx.c	2005-03-12 16:10:40.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_plx.c	2005-03-12 16:10:50.000000000 -0800
@@ -20,6 +20,7 @@
 
 #include <linux/ioport.h>
 #include <linux/pci.h>
+#include <asm/io.h>
 
 #include "hostap_wlan.h"
 

-- 
Jouni Malinen                                            PGP id EFC895FA
