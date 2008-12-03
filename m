From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] netdev: remove pathetic compile-command lines
Date: Thu, 4 Dec 2008 02:35:26 +0300
Message-ID: <20081203233526.GA2448@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:4574 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754464AbYLCXbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 18:31:14 -0500
Received: by ug-out-1314.google.com with SMTP id 39so3573626ugf.37
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2008 15:31:12 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-m486, -O6 are partircularly amusing.

Remove some other useless lines near as well.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/3c507.c          |   11 -----------
 drivers/net/3c515.c          |    8 --------
 drivers/net/82596.c          |    6 ------
 drivers/net/acenic.c         |    7 -------
 drivers/net/appletalk/cops.c |    8 --------
 drivers/net/at1700.c         |   12 ------------
 drivers/net/de620.c          |   17 -----------------
 drivers/net/defxx.c          |    7 -------
 drivers/net/eth16i.c         |   12 ------------
 drivers/net/ewrk3.c          |   10 ----------
 drivers/net/hp100.c          |    9 ---------
 drivers/net/isa-skeleton.c   |   12 ------------
 drivers/net/mac89x0.c        |   11 -----------
 drivers/net/ni5010.c         |    9 ---------
 drivers/net/ni52.c           |    6 ------
 drivers/net/ni65.c           |    6 ------
 drivers/net/plip.c           |    6 ------
 drivers/net/rrunner.c        |    6 ------
 drivers/net/seeq8005.c       |    9 ---------
 drivers/net/yellowfin.c      |   11 -----------
 20 files changed, 183 deletions(-)

--- a/drivers/net/3c507.c
+++ b/drivers/net/3c507.c
@@ -936,14 +936,3 @@ cleanup_module(void)
 }
 #endif /* MODULE */
 MODULE_LICENSE("GPL");
-
-
-/*
- * Local variables:
- *  compile-command: "gcc -D__KERNEL__ -I/usr/src/linux/net/inet -I/usr/src/linux/drivers/net -Wall -Wstrict-prototypes -O6 -m486 -c 3c507.c"
- *  version-control: t
- *  kept-new-versions: 5
- *  tab-width: 4
- *  c-indent-level: 4
- * End:
- */
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -1577,11 +1577,3 @@ void cleanup_module(void)
 	}
 }
 #endif				/* MODULE */
-
-/*
- * Local variables:
- *  compile-command: "gcc -DMODULE -D__KERNEL__ -Wall -Wstrict-prototypes -O6 -c 3c515.c"
- *  c-indent-level: 4
- *  tab-width: 4
- * End:
- */
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -1598,9 +1598,3 @@ void __exit cleanup_module(void)
 }
 
 #endif				/* MODULE */
-
-/*
- * Local variables:
- *  compile-command: "gcc -D__KERNEL__ -I/usr/src/linux/net/inet -Wall -Wstrict-prototypes -O6 -m486 -c 82596.c"
- * End:
- */
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -3224,10 +3224,3 @@ static int __devinit read_eeprom_byte(struct net_device *dev,
 	       ap->name, offset);
 	goto out;
 }
-
-
-/*
- * Local variables:
- * compile-command: "gcc -D__SMP__ -D__KERNEL__ -DMODULE -I../../include -Wall -Wstrict-prototypes -O2 -fomit-frame-pointer -pipe -fno-strength-reduce -DMODVERSIONS -include ../../include/linux/modversions.h   -c -o acenic.o acenic.c"
- * End:
- */
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -1024,11 +1024,3 @@ static void __exit cops_module_exit(void)
 module_init(cops_module_init);
 module_exit(cops_module_exit);
 #endif /* MODULE */
-
-/*
- * Local variables:
- *  compile-command: "gcc -DMODVERSIONS -DMODULE -D__KERNEL__ -Wall -Wstrict-prototypes -O2 -c cops.c"
- *  c-basic-offset: 4
- *  c-file-offsets: ((substatement-open . 0))
- * End:
- */
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -899,15 +899,3 @@ module_init(at1700_module_init);
 module_exit(at1700_module_exit);
 #endif /* MODULE */
 MODULE_LICENSE("GPL");
-
-
-/*
- * Local variables:
- *  compile-command: "gcc -DMODULE -D__KERNEL__ -Wall -Wstrict-prototypes -O6 -c at1700.c"
- *  alt-compile-command: "gcc -DMODVERSIONS -DMODULE -D__KERNEL__ -Wall -Wstrict-prototypes -O6 -c at1700.c"
- *  tab-width: 4
- *  c-basic-offset: 4
- *  c-indent-level: 4
- * End:
- */
-
--- a/drivers/net/de620.c
+++ b/drivers/net/de620.c
@@ -1003,20 +1003,3 @@ void cleanup_module(void)
 }
 #endif /* MODULE */
 MODULE_LICENSE("GPL");
-
-
-/*
- * (add '-DMODULE' when compiling as loadable module)
- *
- * compile-command:
- *	gcc -D__KERNEL__ -Wall -Wstrict-prototypes -O2 \
- *	 -fomit-frame-pointer -m486 \
- *	-I/usr/src/linux/include -I../../net/inet -c de620.c
-*/
-/*
- * Local variables:
- *  kernel-compile-command: "gcc -D__KERNEL__ -Ilinux/include -I../../net/inet -Wall -Wstrict-prototypes -O2 -m486 -c de620.c"
- *  module-compile-command: "gcc -D__KERNEL__ -DMODULE -Ilinux/include -I../../net/inet -Wall -Wstrict-prototypes -O2 -m486 -c de620.c"
- *  compile-command: "gcc -D__KERNEL__ -DMODULE -Ilinux/include -I../../net/inet -Wall -Wstrict-prototypes -O2 -m486 -c de620.c"
- * End:
- */
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -3743,10 +3743,3 @@ MODULE_AUTHOR("Lawrence V. Stefani");
 MODULE_DESCRIPTION("DEC FDDIcontroller TC/EISA/PCI (DEFTA/DEFEA/DEFPA) driver "
 		   DRV_VERSION " " DRV_RELDATE);
 MODULE_LICENSE("GPL");
-
-
-/*
- * Local variables:
- * kernel-compile-command: "gcc -D__KERNEL__ -I/root/linux/include -Wall -Wstrict-prototypes -O2 -pipe -fomit-frame-pointer -fno-strength-reduce -m486 -malign-loops=2 -malign-jumps=2 -malign-functions=2 -c defxx.c"
- * End:
- */
--- a/drivers/net/eth16i.c
+++ b/drivers/net/eth16i.c
@@ -1474,15 +1474,3 @@ void __exit cleanup_module(void)
 	}
 }
 #endif /* MODULE */
-
-/*
- * Local variables:
- *  compile-command: "gcc -DMODULE -D__KERNEL__ -Wall -Wstrict-prototypes -O6 -c eth16i.c"
- *  alt-compile-command: "gcc -DMODVERSIONS -DMODULE -D__KERNEL__ -Wall -Wstrict -prototypes -O6 -c eth16i.c"
- *  tab-width: 8
- *  c-basic-offset: 8
- *  c-indent-level: 8
- * End:
- */
-
-/* End of file eth16i.c */
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -1967,13 +1967,3 @@ module_exit(ewrk3_exit_module);
 module_init(ewrk3_init_module);
 #endif				/* MODULE */
 MODULE_LICENSE("GPL");
-
-
-
-/*
- * Local variables:
- *  compile-command: "gcc -D__KERNEL__ -I/linux/include -Wall -Wstrict-prototypes -fomit-frame-pointer -fno-strength-reduce -malign-loops=2 -malign-jumps=2 -malign-functions=2 -O2 -m486 -c ewrk3.c"
- *
- *  compile-command: "gcc -D__KERNEL__ -DMODULE -I/linux/include -Wall -Wstrict-prototypes -fomit-frame-pointer -fno-strength-reduce -malign-loops=2 -malign-jumps=2 -malign-functions=2 -O2 -m486 -c ewrk3.c"
- * End:
- */
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -3054,12 +3054,3 @@ static void __exit hp100_module_exit(void)
 
 module_init(hp100_module_init)
 module_exit(hp100_module_exit)
-
-
-/*
- * Local variables:
- *  compile-command: "gcc -D__KERNEL__ -I/usr/src/linux/net/inet -Wall -Wstrict-prototypes -O6 -m486 -c hp100.c"
- *  c-indent-level: 2
- *  tab-width: 8
- * End:
- */
--- a/drivers/net/isa-skeleton.c
+++ b/drivers/net/isa-skeleton.c
@@ -709,15 +709,3 @@ cleanup_module(void)
 }
 
 #endif /* MODULE */
-
-/*
- * Local variables:
- *  compile-command:
- *	gcc -D__KERNEL__ -Wall -Wstrict-prototypes -Wwrite-strings
- *	-Wredundant-decls -O2 -m486 -c skeleton.c
- *  version-control: t
- *  kept-new-versions: 5
- *  tab-width: 4
- *  c-indent-level: 4
- * End:
- */
--- a/drivers/net/mac89x0.c
+++ b/drivers/net/mac89x0.c
@@ -625,14 +625,3 @@ cleanup_module(void)
 	free_netdev(dev_cs89x0);
 }
 #endif /* MODULE */
-
-/*
- * Local variables:
- *  compile-command: "m68k-linux-gcc -D__KERNEL__ -I../../include -Wall -Wstrict-prototypes -O2 -fomit-frame-pointer -pipe -fno-strength-reduce -ffixed-a2 -DMODULE -DMODVERSIONS -include ../../include/linux/modversions.h   -c -o mac89x0.o mac89x0.c"
- *  version-control: t
- *  kept-new-versions: 5
- *  c-indent-level: 8
- *  tab-width: 8
- * End:
- *
- */
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -766,12 +766,3 @@ module_init(ni5010_init_module);
 module_exit(ni5010_cleanup_module);
 #endif /* MODULE */
 MODULE_LICENSE("GPL");
-
-/*
- * Local variables:
- *  compile-command: "gcc -D__KERNEL__ -I/usr/src/linux/net/inet -Wall -Wstrict-prototypes -O6 -m486 -c ni5010.c"
- *  version-control: t
- *  kept-new-versions: 5
- *  tab-width: 4
- * End:
- */
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -9,8 +9,6 @@
  *    [feel free to mail ....]
  *
  * when using as module: (no autoprobing!)
- *   compile with:
- *       gcc -O2 -fomit-frame-pointer -m486 -D__KERNEL__ -DMODULE -c ni52.c
  *   run with e.g:
  *       insmod ni52.o io=0x360 irq=9 memstart=0xd0000 memend=0xd4000
  *
@@ -1345,7 +1343,3 @@ void __exit cleanup_module(void)
 #endif /* MODULE */
 
 MODULE_LICENSE("GPL");
-
-/*
- * END: linux/drivers/net/ni52.c
- */
--- a/drivers/net/ni65.c
+++ b/drivers/net/ni65.c
@@ -7,8 +7,6 @@
  * EtherBlaster. (probably it also works with every full NE2100
  * compatible card)
  *
- * To compile as module, type:
- *     gcc -O2 -fomit-frame-pointer -m486 -D__KERNEL__ -DMODULE -c ni65.c
  * driver probes: io: 0x360,0x300,0x320,0x340 / dma: 3,5,6,7
  *
  * This is an extension to the Linux operating system, and is covered by the
@@ -1265,7 +1263,3 @@ void __exit cleanup_module(void)
 #endif /* MODULE */
 
 MODULE_LICENSE("GPL");
-
-/*
- * END of ni65.c
- */
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -1396,9 +1396,3 @@ static int __init plip_init (void)
 module_init(plip_init);
 module_exit(plip_cleanup_module);
 MODULE_LICENSE("GPL");
-
-/*
- * Local variables:
- * compile-command: "gcc -DMODULE -DMODVERSIONS -D__KERNEL__ -Wall -Wstrict-prototypes -O2 -g -fomit-frame-pointer -pipe -c plip.c"
- * End:
- */
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -1713,9 +1713,3 @@ static void __exit rr_cleanup_module(void)
 
 module_init(rr_init_module);
 module_exit(rr_cleanup_module);
-
-/*
- * Local variables:
- * compile-command: "gcc -D__KERNEL__ -I../../include -Wall -Wstrict-prototypes -O2 -pipe -fomit-frame-pointer -fno-strength-reduce -m486 -malign-loops=2 -malign-jumps=2 -malign-functions=2 -DMODULE -DMODVERSIONS -include ../../include/linux/modversions.h -c rrunner.c"
- * End:
- */
--- a/drivers/net/seeq8005.c
+++ b/drivers/net/seeq8005.c
@@ -744,12 +744,3 @@ void __exit cleanup_module(void)
 }
 
 #endif /* MODULE */
-
-/*
- * Local variables:
- *  compile-command: "gcc -D__KERNEL__ -I/usr/src/linux/net/inet -Wall -Wstrict-prototypes -O6 -m486 -c skeleton.c"
- *  version-control: t
- *  kept-new-versions: 5
- *  tab-width: 4
- * End:
- */
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -1424,14 +1424,3 @@ static void __exit yellowfin_cleanup (void)
 
 module_init(yellowfin_init);
 module_exit(yellowfin_cleanup);
-
-/*
- * Local variables:
- *  compile-command: "gcc -DMODULE -Wall -Wstrict-prototypes -O6 -c yellowfin.c"
- *  compile-command-alphaLX: "gcc -DMODULE -Wall -Wstrict-prototypes -O2 -c yellowfin.c -fomit-frame-pointer -fno-strength-reduce -mno-fp-regs -Wa,-m21164a -DBWX_USABLE -DBWIO_ENABLED"
- *  simple-compile-command: "gcc -DMODULE -O6 -c yellowfin.c"
- *  c-indent-level: 4
- *  c-basic-offset: 4
- *  tab-width: 4
- * End:
- */
