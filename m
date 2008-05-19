From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] drivers/net/: remove CVS keywords
Date: Tue, 20 May 2008 01:06:19 +0300
Message-ID: <20080519220619.GL17716@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:45175 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764838AbYESWIZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 18:08:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes some CVS keywords that weren't updated for a long 
time.

I haven't touched drivers that looked as if they might still be used.

In three drivers I've also removed printk's printing them since they 
were part of several printk's in a row and it doesn't make sense to 
print ancient version information to the user.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 drivers/net/3c505.c                   |    2 --
 drivers/net/3c523.c                   |    2 --
 drivers/net/3c523.h                   |    2 --
 drivers/net/82596.c                   |    5 -----
 drivers/net/appletalk/ltpc.c          |    1 -
 drivers/net/de600.c                   |    4 ----
 drivers/net/de620.c                   |    8 --------
 drivers/net/eql.c                     |    1 -
 drivers/net/hamradio/scc.c            |    2 --
 drivers/net/hp100.c                   |    2 --
 drivers/net/hp100.h                   |    2 --
 drivers/net/ns83820.c                 |    2 --
 drivers/net/plip.c                    |    1 -
 drivers/net/sunbmac.c                 |    2 +-
 drivers/net/sunbmac.h                 |    2 +-
 drivers/net/sungem.c                  |    2 +-
 drivers/net/sungem.h                  |    2 +-
 drivers/net/sunhme.h                  |    2 +-
 drivers/net/sunlance.c                |    2 +-
 drivers/net/sunqe.h                   |    2 +-
 drivers/net/tg3.h                     |    2 +-
 drivers/net/tulip/xircom_cb.c         |    3 ---
 drivers/net/tun.c                     |    2 --
 drivers/net/wan/cosa.c                |    2 --
 drivers/net/wan/cosa.h                |    2 --
 drivers/net/wan/hd64572.h             |    1 -
 drivers/net/wan/lmc/lmc_ioctl.h       |    2 --
 drivers/net/wan/lmc/lmc_main.c        |    2 --
 drivers/net/wan/lmc/lmc_media.c       |    2 --
 drivers/net/wan/lmc/lmc_var.h         |    2 --
 drivers/net/wan/pc300-falc-lh.h       |    1 -
 drivers/net/wan/pc300.h               |    1 -
 drivers/net/wan/pc300_drv.c           |    1 -
 drivers/net/wan/pc300_tty.c           |    1 -
 drivers/net/wan/syncppp.c             |    2 --
 drivers/net/wireless/airo_cs.c        |    1 -
 drivers/net/wireless/atmel_cs.c       |    1 -
 drivers/net/wireless/prism54/Makefile |    2 --
 include/linux/scc.h                   |    2 --
 39 files changed, 8 insertions(+), 72 deletions(-)

e5203fb5570e631985e9592326d2c02ba60e5cb9 diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index fdfb2b2..a63200b 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -10,8 +10,6 @@
  *              be here without 3C505 technical reference provided by
  *              3Com.
  *
- * $Id: 3c505.c,v 1.10 1996/04/16 13:06:27 phil Exp $
- *
  * Authors:     Linux 3c505 device driver by
  *                      Craig Southeren, <craigs@ineluki.apana.org.au>
  *              Final debugging by
diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index 239fc42..a74e5de 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -83,8 +83,6 @@
        Stuart Adamson <stuart.adamson@compsoc.net>
    Nov 2001
    added support for ethtool (jgarzik)
-
-   $Header: /fsys2/home/chrisb/linux-1.3.59-MCA/drivers/net/RCS/3c523.c,v 1.1 1996/02/05 01:53:46 chrisb Exp chrisb $
  */
 
 #define DRV_NAME		"3c523"
diff --git a/drivers/net/3c523.h b/drivers/net/3c523.h
index 6956441..f7f265b 100644
--- a/drivers/net/3c523.h
+++ b/drivers/net/3c523.h
@@ -14,8 +14,6 @@
  * Copyright 1995 by Chris Beauregard (cpbeaure@undergrad.math.uwaterloo.ca)
  *
  * See 3c523.c for details.
- *
- * $Header: /home/chrisb/linux-1.2.13-3c523/drivers/net/RCS/3c523.h,v 1.6 1996/01/20 05:09:00 chrisb Exp chrisb $
  */
 
 /*
diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index 2797da7..55eb8cf 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -59,9 +59,6 @@
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
 
-static char version[] __initdata =
-	"82596.c $Revision: 1.5 $\n";
-
 #define DRV_NAME	"82596"
 
 /* DEBUG flags
@@ -1227,8 +1224,6 @@ struct net_device * __init i82596_probe(int unit)
 
 	DEB(DEB_PROBE,printk(" IRQ %d.\n", dev->irq));
 
-	DEB(DEB_PROBE,printk(KERN_INFO "%s", version));
-
 	/* The 82596-specific entries in the device structure. */
 	dev->open = i596_open;
 	dev->stop = i596_close;
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index fef5560..90ed09a 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -61,7 +61,6 @@
 
 /***
  *
- * $Log: ltpc.c,v $
  * Revision 1.1.2.1  2000/03/01 05:35:07  jgarzik
  * at and tr cleanup
  *
diff --git a/drivers/net/de600.c b/drivers/net/de600.c
index cb849b0..276286b 100644
--- a/drivers/net/de600.c
+++ b/drivers/net/de600.c
@@ -1,4 +1,3 @@
-static const char version[] = "de600.c: $Revision: 1.41-2.5 $,  Bjorn Ekwall (bj0rn@blox.se)\n";
 /*
  *	de600.c
  *
@@ -398,9 +397,6 @@ static struct net_device * __init de600_probe(void)
 	}
 
 	printk(KERN_INFO "%s: D-Link DE-600 pocket adapter", dev->name);
-	/* Alpha testers must have the version number to report bugs. */
-	if (de600_debug > 1)
-		printk(version);
 
 	/* probe for adapter */
 	err = -ENODEV;
diff --git a/drivers/net/de620.c b/drivers/net/de620.c
index 3f5190c..18a482d 100644
--- a/drivers/net/de620.c
+++ b/drivers/net/de620.c
@@ -1,7 +1,4 @@
 /*
- *	de620.c $Revision: 1.40 $ BETA
- *
- *
  *	Linux driver for the D-Link DE-620 Ethernet pocket adapter.
  *
  *	Portions (C) Copyright 1993, 1994 by Bjorn Ekwall <bj0rn@blox.se>
@@ -38,8 +35,6 @@
  *	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  *
  *****************************************************************************/
-static const char version[] =
-	"de620.c: $Revision: 1.40 $,  Bjorn Ekwall <bj0rn@blox.se>\n";
 
 /***********************************************************************
  *
@@ -828,9 +823,6 @@ struct net_device * __init de620_probe(int unit)
 		netdev_boot_setup_check(dev);
 	}
 
-	if (de620_debug)
-		printk(version);
-
 	printk(KERN_INFO "D-Link DE-620 pocket adapter");
 
 	if (!request_region(dev->base_addr, 3, "de620")) {
diff --git a/drivers/net/eql.c b/drivers/net/eql.c
index 18f1364..13ddf1e 100644
--- a/drivers/net/eql.c
+++ b/drivers/net/eql.c
@@ -28,7 +28,6 @@
  */
 
 /*
- * $Log: eql.c,v $
  * Revision 1.2  1996/04/11 17:51:52  guru
  * Added one-line eql_remove_slave patch.
  *
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index f905159..dfd492e 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -1,5 +1,3 @@
-#define RCS_ID "$Id: scc.c,v 1.75 1998/11/04 15:15:01 jreuter Exp jreuter $"
-
 #define VERSION "3.0"
 
 /*
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index 571dd80..da2a56f 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -2,8 +2,6 @@
 ** hp100.c
 ** HP CASCADE Architecture Driver for 100VG-AnyLan Network Adapters
 **
-** $Id: hp100.c,v 1.58 2001/09/24 18:03:01 perex Exp perex $
-**
 ** Based on the HP100 driver written by Jaroslav Kysela <perex@jcu.cz>
 ** Extended for new busmaster capable chipsets by
 ** Siegfried "Frieder" Loeffler (dg1sek) <floeff@mathematik.uni-stuttgart.de>
diff --git a/drivers/net/hp100.h b/drivers/net/hp100.h
index e6ca128..7517857 100644
--- a/drivers/net/hp100.h
+++ b/drivers/net/hp100.h
@@ -1,8 +1,6 @@
 /*
  * hp100.h: Hewlett Packard HP10/100VG ANY LAN ethernet driver for Linux.
  *
- * $Id: hp100.h,v 1.51 1997/04/08 14:26:42 floeff Exp floeff $
- *
  * Authors:  Jaroslav Kysela, <perex@pf.jcu.cz>
  *           Siegfried Loeffler <floeff@tunix.mathematik.uni-stuttgart.de>
  *
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index b42c05f..63ae0e5 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -3,8 +3,6 @@
  *
  * Questions/comments/discussion to linux-ns83820@kvack.org.
  *
- * $Revision: 1.34.2.23 $
- *
  * Copyright 2001 Benjamin LaHaise.
  * Copyright 2001, 2002 Red Hat.
  *
diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index 1e96542..bd274cc 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -1,4 +1,3 @@
-/* $Id: plip.c,v 1.3.6.2 1997/04/16 15:07:56 phil Exp $ */
 /* PLIP: A parallel port "network" driver for Linux. */
 /* This driver is for parallel port with 5-bit cable (LapLink (R) cable). */
 /*
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index 0e4a88d..87b5755 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -1,4 +1,4 @@
-/* $Id: sunbmac.c,v 1.30 2002/01/15 06:48:55 davem Exp $
+/*
  * sunbmac.c: Driver for Sparc BigMAC 100baseT ethernet adapters.
  *
  * Copyright (C) 1997, 1998, 1999, 2003 David S. Miller (davem@redhat.com)
diff --git a/drivers/net/sunbmac.h b/drivers/net/sunbmac.h
index b563d3c..0ce8b05 100644
--- a/drivers/net/sunbmac.h
+++ b/drivers/net/sunbmac.h
@@ -1,4 +1,4 @@
-/* $Id: sunbmac.h,v 1.7 2000/07/11 22:35:22 davem Exp $
+/*
  * sunbmac.h: Defines for the Sun "Big MAC" 100baseT ethernet cards.
  *
  * Copyright (C) 1997 David S. Miller (davem@caip.rutgers.edu)
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 4291458..74489b3 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -1,4 +1,4 @@
-/* $Id: sungem.c,v 1.44.2.22 2002/03/13 01:18:12 davem Exp $
+/*
  * sungem.c: Sun GEM ethernet driver.
  *
  * Copyright (C) 2000, 2001, 2002, 2003 David S. Miller (davem@redhat.com)
diff --git a/drivers/net/sungem.h b/drivers/net/sungem.h
index f7a0291..e4d5619 100644
--- a/drivers/net/sungem.h
+++ b/drivers/net/sungem.h
@@ -1,4 +1,4 @@
-/* $Id: sungem.h,v 1.10.2.4 2002/03/11 08:54:48 davem Exp $
+/*
  * sungem.h: Definitions for Sun GEM ethernet driver.
  *
  * Copyright (C) 2000 David S. Miller (davem@redhat.com)
diff --git a/drivers/net/sunhme.h b/drivers/net/sunhme.h
index 4da5539..0b81fa7 100644
--- a/drivers/net/sunhme.h
+++ b/drivers/net/sunhme.h
@@ -1,4 +1,4 @@
-/* $Id: sunhme.h,v 1.33 2001/08/03 06:23:04 davem Exp $
+/*
  * sunhme.h: Definitions for Sparc HME/BigMac 10/100baseT ethernet driver.
  *           Also known as the "Happy Meal".
  *
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index 26ade68..64fdd9d 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1,4 +1,4 @@
-/* $Id: sunlance.c,v 1.112 2002/01/15 06:48:55 davem Exp $
+/*
  * lance.c: Linux/Sparc/Lance driver
  *
  *	Written 1995, 1996 by Miguel de Icaza
diff --git a/drivers/net/sunqe.h b/drivers/net/sunqe.h
index 347c8dd..83f4423 100644
--- a/drivers/net/sunqe.h
+++ b/drivers/net/sunqe.h
@@ -1,4 +1,4 @@
-/* $Id: sunqe.h,v 1.13 2000/02/09 11:15:42 davem Exp $
+/*
  * sunqe.h: Definitions for the Sun QuadEthernet driver.
  *
  * Copyright (C) 1996 David S. Miller (davem@caip.rutgers.edu)
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 0404f93..3da0f28 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1,4 +1,4 @@
-/* $Id: tg3.h,v 1.37.2.32 2002/03/11 12:18:18 davem Exp $
+/*
  * tg3.h: Definitions for Broadcom Tigon3 ethernet driver.
  *
  * Copyright (C) 2001, 2002, 2003, 2004 David S. Miller (davem@redhat.com)
diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index 6b93d01..5e412e5 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -9,9 +9,6 @@
  *
  *  	This software may be used and distributed according to the terms
  *      of the GNU General Public License, incorporated herein by reference.
- *
- *
- * 	$Id: xircom_cb.c,v 1.33 2001/03/19 14:02:07 arjanv Exp $
  */
 
 #include <linux/module.h>
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 0ce07a3..c856f23 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -11,8 +11,6 @@
  *  but WITHOUT ANY WARRANTY; without even the implied warranty of
  *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  *  GNU General Public License for more details.
- *
- *  $Id: tun.c,v 1.15 2002/03/01 02:44:24 maxk Exp $
  */
 
 /*
diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index b0fce13..6e2d499 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -1,5 +1,3 @@
-/* $Id: cosa.c,v 1.31 2000/03/08 17:47:16 kas Exp $ */
-
 /*
  *  Copyright (C) 1995-1997  Jan "Yenya" Kasprzak <kas@fi.muni.cz>
  *
diff --git a/drivers/net/wan/cosa.h b/drivers/net/wan/cosa.h
index 028f3d9..51695ae 100644
--- a/drivers/net/wan/cosa.h
+++ b/drivers/net/wan/cosa.h
@@ -1,5 +1,3 @@
-/* $Id: cosa.h,v 1.6 1999/01/06 14:02:44 kas Exp $ */
-
 /*
  *  Copyright (C) 1995-1997  Jan "Yenya" Kasprzak <kas@fi.muni.cz>
  *
diff --git a/drivers/net/wan/hd64572.h b/drivers/net/wan/hd64572.h
index 96567c2..6628f16 100644
--- a/drivers/net/wan/hd64572.h
+++ b/drivers/net/wan/hd64572.h
@@ -11,7 +11,6 @@
  *	as published by the Free Software Foundation; either version
  *	2 of the License, or (at your option) any later version.
  *
- * $Log: hd64572.h,v $
  * Revision 3.1  2001/06/15 12:41:10  regina
  * upping major version number
  *
diff --git a/drivers/net/wan/lmc/lmc_ioctl.h b/drivers/net/wan/lmc/lmc_ioctl.h
index 57dd861..a2925c0 100644
--- a/drivers/net/wan/lmc/lmc_ioctl.h
+++ b/drivers/net/wan/lmc/lmc_ioctl.h
@@ -1,7 +1,5 @@
 #ifndef _LMC_IOCTL_H_
 #define _LMC_IOCTL_H_
-/*	$Id: lmc_ioctl.h,v 1.15 2000/04/06 12:16:43 asj Exp $	*/
-
  /*
   * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
   * All rights reserved.  www.lanmedia.com
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 62133ce..1aada9c 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -36,8 +36,6 @@
   *
   */
 
-/* $Id: lmc_main.c,v 1.36 2000/04/11 05:25:25 asj Exp $ */
-
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/string.h>
diff --git a/drivers/net/wan/lmc/lmc_media.c b/drivers/net/wan/lmc/lmc_media.c
index 8aa461c..0f7452f 100644
--- a/drivers/net/wan/lmc/lmc_media.c
+++ b/drivers/net/wan/lmc/lmc_media.c
@@ -1,5 +1,3 @@
-/* $Id: lmc_media.c,v 1.13 2000/04/11 05:25:26 asj Exp $ */
-
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/timer.h>
diff --git a/drivers/net/wan/lmc/lmc_var.h b/drivers/net/wan/lmc/lmc_var.h
index 6d003a3..0ca8927 100644
--- a/drivers/net/wan/lmc/lmc_var.h
+++ b/drivers/net/wan/lmc/lmc_var.h
@@ -1,8 +1,6 @@
 #ifndef _LMC_VAR_H_
 #define _LMC_VAR_H_
 
-/* $Id: lmc_var.h,v 1.17 2000/04/06 12:16:47 asj Exp $ */
-
  /*
   * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
   * All rights reserved.  www.lanmedia.com
diff --git a/drivers/net/wan/pc300-falc-lh.h b/drivers/net/wan/pc300-falc-lh.h
index 01ed23c..8545668 100644
--- a/drivers/net/wan/pc300-falc-lh.h
+++ b/drivers/net/wan/pc300-falc-lh.h
@@ -10,7 +10,6 @@
  *	as published by the Free Software Foundation; either version
  *	2 of the License, or (at your option) any later version.
  *
- * $Log: falc-lh.h,v $
  * Revision 3.1  2001/06/15 12:41:10  regina
  * upping major version number
  *
diff --git a/drivers/net/wan/pc300.h b/drivers/net/wan/pc300.h
index 63e9fcf..d61554c 100644
--- a/drivers/net/wan/pc300.h
+++ b/drivers/net/wan/pc300.h
@@ -10,7 +10,6 @@
  *	as published by the Free Software Foundation; either version
  *	2 of the License, or (at your option) any later version.
  *
- * $Log: pc300.h,v $
  * Revision 3.12  2002/03/07 14:17:09  henrique
  * License data fixed
  *
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 57914fb..21b7d38 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -17,7 +17,6 @@ static char rcsid[] =
  *	
  *	Using tabstop = 4.
  * 
- * $Log: pc300_drv.c,v $
  * Revision 3.23  2002/03/20 13:58:40  henrique
  * Fixed ortographic mistakes
  *
diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index e03eef2..66b784e 100644
--- a/drivers/net/wan/pc300_tty.c
+++ b/drivers/net/wan/pc300_tty.c
@@ -10,7 +10,6 @@
  *  as published by the Free Software Foundation; either version
  *  2 of the License, or (at your option) any later version.
  *   
- *  $Log: pc300_tty.c,v $
  *  Revision 3.7  2002/03/07 14:17:09  henrique
  *  License data fixed
  *
diff --git a/drivers/net/wan/syncppp.c b/drivers/net/wan/syncppp.c
index 29b4b94..dac612e 100644
--- a/drivers/net/wan/syncppp.c
+++ b/drivers/net/wan/syncppp.c
@@ -32,8 +32,6 @@
  * all derivative works or modified versions.
  *
  * Version 1.9, Wed Oct  4 18:58:15 MSK 1995
- *
- * $Id: syncppp.c,v 1.18 2000/04/11 05:25:31 asj Exp $
  */
 #undef DEBUG
 
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index f123553..fd0ea6f 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -53,7 +53,6 @@
 #ifdef PCMCIA_DEBUG
 static int pc_debug = PCMCIA_DEBUG;
 module_param(pc_debug, int, 0);
-static char *version = "$Revision: 1.2 $";
 #define DEBUG(n, args...) if (pc_debug>(n)) printk(KERN_DEBUG args);
 #else
 #define DEBUG(n, args...)
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index 12617cd..526cb5b 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -66,7 +66,6 @@
 #ifdef PCMCIA_DEBUG
 static int pc_debug = PCMCIA_DEBUG;
 module_param(pc_debug, int, 0);
-static char *version = "$Revision: 1.2 $";
 #define DEBUG(n, args...) if (pc_debug>(n)) printk(KERN_DEBUG args);
 #else
 #define DEBUG(n, args...)
diff --git a/drivers/net/wireless/prism54/Makefile b/drivers/net/wireless/prism54/Makefile
index fad305c..d54fb3c 100644
--- a/drivers/net/wireless/prism54/Makefile
+++ b/drivers/net/wireless/prism54/Makefile
@@ -1,5 +1,3 @@
-# $Id: Makefile.k26,v 1.7 2004/01/30 16:24:00 ajfa Exp $
-
 prism54-objs := islpci_eth.o islpci_mgt.o \
                 isl_38xx.o isl_ioctl.o islpci_dev.o \
 		islpci_hotplug.o oid_mgt.o
diff --git a/include/linux/scc.h b/include/linux/scc.h
index 3495bd9..6ebb065 100644
--- a/include/linux/scc.h
+++ b/include/linux/scc.h
@@ -1,5 +1,3 @@
-/* $Id: scc.h,v 1.29 1997/04/02 14:56:45 jreuter Exp jreuter $ */
-
 #ifndef	_SCC_H
 #define	_SCC_H
 

