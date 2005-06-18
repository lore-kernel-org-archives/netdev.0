From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 9/9] orinoco: update changelog and version
Date: Sun, 19 Jun 2005 01:28:12 +0200
Message-ID: <20050618232812.GJ9918@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, proski@gnu.org, hermes@gibson.dropbear.id.au
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


diff -urp -X /home/hch/dontdiff linux-2.6/drivers/net/wireless/orinoco.c orinoco/orinoco.c
--- linux-2.6/drivers/net/wireless/orinoco.c	2005-05-14 13:49:02.000000000 +0200
+++ orinoco/orinoco.c	2005-05-14 13:05:46.000000000 +0200
@@ -416,12 +416,50 @@
  *	  port.  This is supposed to allow 802.1x to work sanely, but
  *	  doesn't seem to yet.
  *
+ * v0.14alpha2 -> v0.15rc1 - 19 Apr 2004 - Pavel Roskin & David Gibson
+ *	o Fix bug which prevented setting 32 character ESSIDs from
+ *	  iwconfig (Thomas Schulz).
+ *	o Fix for incorrect CIS access in orinoco_plx (Pavel Roskin).
+ *	o Fix setting WEP key if __orinoco_fastkeychange() is not
+ *	  supported (Pavel Roskin).
+ *	o New wireless extensions API and scanning support (patch from
+ *	  Moustafa Youssef, updated by Jim Carter and Pavel Roskin).
+ *	o Add minimal ethtool support (Pavel Roskin).
+ *	o Replace CardServices() calls for compatibility with Linux
+ *	  2.6.2 and above (Pavel Roskin).
+ *	o Fix recognition of Intersil x.x.1 firmware (Pavel Roskin).
+ *	o Replace dump_recs with more flexible get_rid ioctl (Pavel
+ *	  Roskin).
+ *	o RF monitor mode support (Pavel Roskin).
+ *	o Lots of bugfixes.
+ *
+ * v0.15rc1 -> v0.15rc2 - 28 Jul 2004 - Pavel Roskin & David Gibson
+ *	o orinoco_pci saves PCI registers on suspend (Simon Huggins).
+ *	o Monitor mode disabled on Agere 8.xx firmware - it's broken.
+ *	o BAP timeout increased - needed for Intersil firmware.
+ *	o Tx power is no longer reported - it's unreliable.
+ *	o Use 802.11 header in rx path.  Hide packets with ToDS flag
+ *	  from programs that don't need promiscous mode (John Denker).
+ *	o Manual roaming implemented for Symbol and Intersil firmware.
+ *	o Use netdev_priv() instead of directly dereferencing dev->priv.
+ *	o Some simplification of pcmcia init code in orinoco_cs and
+ *	  spectrum_cs. 
+ *	o Numerous trivial cleanups, mainly arising from long-overdue
+ *	  merge with mainline.
+ *
+ * v0.15rc2 -> ???? - ???? - David Gibson
+ *	o Use ssleep() or msleep() instead of hardcoded
+ *	  schedule_timeout()s (Nishanth Aravamudan via kernel-janitors
+ *	  list).
+ *	o Several cleanups and bugfixes in pci/plx/tmd/nortel drivers.
+ *	o Fix memory leak in orinoco_join_ap().
+ *	o Change io handling to avoid sparse and gcc warnings.
+ *	o Use C99 array initializers and ARRAY_SIZE() for iw_handler
+ *	  tables.
+ *
  * TODO
- *	o New wireless extensions API (patch from Moustafa
- *	  Youssef, updated by Jim Carter and Pavel Roskin).
  *	o Handle de-encapsulation within network layer, provide 802.11
  *	  headers (patch from Thomas 'Dent' Mirlacher)
- *	o RF monitor mode support
  *	o Fix possible races in SPY handling.
  *	o Disconnect wireless extensions from fundamental configuration.
  *	o (maybe) Software WEP support (patch from Stano Meduna).
diff -urp -X /home/hch/dontdiff linux-2.6/drivers/net/wireless/orinoco.h orinoco/orinoco.h
--- linux-2.6/drivers/net/wireless/orinoco.h	2005-05-14 13:48:44.000000000 +0200
+++ orinoco/orinoco.h	2005-03-18 16:03:24.000000000 +0100
@@ -7,7 +7,7 @@
 #ifndef _ORINOCO_H
 #define _ORINOCO_H
 
-#define DRIVER_VERSION "0.14alpha2"
+#define DRIVER_VERSION "0.15rc2"
 
 #include <linux/types.h>
 #include <linux/spinlock.h>
