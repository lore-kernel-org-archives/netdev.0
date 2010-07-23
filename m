From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 6/6] pcmcia: remove cs_types.h
Date: Fri, 23 Jul 2010 10:38:25 +0200
Message-ID: <1279874305-21191-6-git-send-email-linux@dominikbrodowski.net>
References: <20100723083726.GA20947@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-ide@vger.kernel.org, linux-usb@vger.kernel.org,
	laforge@gnumonks.org, linux-mtd@lists.infradead.org,
	linux-bluetooth@vger.kernel.org, alsa-devel@alsa-project.org,
	linux-serial@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar-3.linta.de ([188.40.101.200]:46201 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754491Ab0GWIjK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jul 2010 04:39:10 -0400
In-Reply-To: <20100723083726.GA20947@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove cs_types.h which is no longer needed: Most definitions aren't
used at all, a few can be made away with, and two remaining definitions
(typedefs, unfortunatley) may be moved to more specific places.

CC: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
CC: linux-ide@vger.kernel.org
CC: linux-usb@vger.kernel.org
CC: laforge@gnumonks.org
CC: linux-mtd@lists.infradead.org
CC: linux-bluetooth@vger.kernel.org
CC: alsa-devel@alsa-project.org
CC: linux-serial@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 Documentation/pcmcia/driver-changes.txt          |    5 +++
 drivers/ata/pata_pcmcia.c                        |    1 -
 drivers/bluetooth/bluecard_cs.c                  |    1 -
 drivers/bluetooth/bt3c_cs.c                      |    1 -
 drivers/bluetooth/btuart_cs.c                    |    1 -
 drivers/bluetooth/dtl1_cs.c                      |    1 -
 drivers/char/pcmcia/cm4000_cs.c                  |    1 -
 drivers/char/pcmcia/cm4040_cs.c                  |    1 -
 drivers/char/pcmcia/ipwireless/main.h            |    1 -
 drivers/char/pcmcia/ipwireless/tty.h             |    1 -
 drivers/char/pcmcia/synclink_cs.c                |    1 -
 drivers/ide/ide-cs.c                             |    1 -
 drivers/isdn/hardware/avm/avm_cs.c               |    1 -
 drivers/isdn/hisax/avma1_cs.c                    |    1 -
 drivers/isdn/hisax/elsa_cs.c                     |    1 -
 drivers/isdn/hisax/sedlbauer_cs.c                |    1 -
 drivers/isdn/hisax/teles_cs.c                    |    1 -
 drivers/mmc/host/sdricoh_cs.c                    |    1 -
 drivers/mtd/maps/pcmciamtd.c                     |    1 -
 drivers/net/pcmcia/3c574_cs.c                    |    1 -
 drivers/net/pcmcia/3c589_cs.c                    |    1 -
 drivers/net/pcmcia/axnet_cs.c                    |    1 -
 drivers/net/pcmcia/com20020_cs.c                 |    1 -
 drivers/net/pcmcia/fmvj18x_cs.c                  |    1 -
 drivers/net/pcmcia/ibmtr_cs.c                    |    1 -
 drivers/net/pcmcia/nmclan_cs.c                   |    1 -
 drivers/net/pcmcia/pcnet_cs.c                    |    5 +--
 drivers/net/pcmcia/smc91c92_cs.c                 |    1 -
 drivers/net/pcmcia/xirc2ps_cs.c                  |    1 -
 drivers/net/wireless/airo_cs.c                   |    1 -
 drivers/net/wireless/atmel_cs.c                  |    1 -
 drivers/net/wireless/b43/pcmcia.c                |    1 -
 drivers/net/wireless/hostap/hostap_cs.c          |    3 +-
 drivers/net/wireless/libertas/if_cs.c            |    1 -
 drivers/net/wireless/orinoco/orinoco_cs.c        |    1 -
 drivers/net/wireless/orinoco/spectrum_cs.c       |    1 -
 drivers/net/wireless/ray_cs.c                    |    1 -
 drivers/net/wireless/wl3501_cs.c                 |   10 +-----
 drivers/parport/parport_cs.c                     |    1 -
 drivers/pcmcia/au1000_generic.h                  |    1 -
 drivers/pcmcia/au1000_pb1x00.c                   |    2 -
 drivers/pcmcia/cistpl.c                          |    1 -
 drivers/pcmcia/cs.c                              |    1 -
 drivers/pcmcia/db1xxx_ss.c                       |    1 -
 drivers/pcmcia/ds.c                              |    1 -
 drivers/pcmcia/i82092.c                          |    1 -
 drivers/pcmcia/i82365.c                          |    1 -
 drivers/pcmcia/m32r_cfc.c                        |    1 -
 drivers/pcmcia/m32r_pcc.c                        |    1 -
 drivers/pcmcia/m8xx_pcmcia.c                     |    1 -
 drivers/pcmcia/pcmcia_cis.c                      |    1 -
 drivers/pcmcia/pcmcia_resource.c                 |    1 -
 drivers/pcmcia/pd6729.c                          |    1 -
 drivers/pcmcia/pxa2xx_base.c                     |    1 -
 drivers/pcmcia/rsrc_iodyn.c                      |    1 -
 drivers/pcmcia/rsrc_mgr.c                        |    1 -
 drivers/pcmcia/rsrc_nonstatic.c                  |    1 -
 drivers/pcmcia/sa1100_generic.c                  |    1 -
 drivers/pcmcia/soc_common.h                      |    1 -
 drivers/pcmcia/socket_sysfs.c                    |    1 -
 drivers/pcmcia/tcic.c                            |    1 -
 drivers/pcmcia/xxs1500_ss.c                      |    1 -
 drivers/pcmcia/yenta_socket.c                    |    1 -
 drivers/scsi/pcmcia/aha152x_stub.c               |    1 -
 drivers/scsi/pcmcia/fdomain_stub.c               |    1 -
 drivers/scsi/pcmcia/nsp_cs.c                     |    1 -
 drivers/scsi/pcmcia/qlogic_stub.c                |    1 -
 drivers/scsi/pcmcia/sym53c500_cs.c               |    1 -
 drivers/serial/serial_cs.c                       |    1 -
 drivers/ssb/main.c                               |    1 -
 drivers/ssb/pcmcia.c                             |    1 -
 drivers/ssb/scan.c                               |    1 -
 drivers/staging/comedi/drivers/cb_das16_cs.c     |    1 -
 drivers/staging/comedi/drivers/das08_cs.c        |    1 -
 drivers/staging/comedi/drivers/ni_daq_700.c      |    1 -
 drivers/staging/comedi/drivers/ni_daq_dio24.c    |    1 -
 drivers/staging/comedi/drivers/ni_labpc_cs.c     |    1 -
 drivers/staging/comedi/drivers/ni_mio_cs.c       |    1 -
 drivers/staging/comedi/drivers/quatech_daqp_cs.c |    1 -
 drivers/staging/wlags49_h2/wl_cs.c               |    1 -
 drivers/staging/wlags49_h2/wl_internal.h         |    1 -
 drivers/telephony/ixj_pcmcia.c                   |    1 -
 drivers/usb/host/sl811_cs.c                      |    5 +--
 include/pcmcia/cistpl.h                          |    2 +
 include/pcmcia/cs.h                              |   10 +-----
 include/pcmcia/cs_types.h                        |   40 ----------------------
 include/pcmcia/ds.h                              |    3 +-
 include/pcmcia/ss.h                              |    1 -
 sound/pcmcia/pdaudiocf/pdaudiocf.h               |    1 -
 sound/pcmcia/vx/vxpocket.h                       |    1 -
 90 files changed, 14 insertions(+), 151 deletions(-)
 delete mode 100644 include/pcmcia/cs_types.h

diff --git a/Documentation/pcmcia/driver-changes.txt b/Documentation/pcmcia/driver-changes.txt
index 61bc4e9..ff5f0be 100644
--- a/Documentation/pcmcia/driver-changes.txt
+++ b/Documentation/pcmcia/driver-changes.txt
@@ -1,4 +1,9 @@
 This file details changes in 2.6 which affect PCMCIA card driver authors:
+* No dev_info_t, no cs_types.h (as of 2.6.36)
+   dev_info_t and a few other typedefs are removed. No longer use them
+   in PCMCIA device drivers. Also, do not include pcmcia/cs_types.h, as
+   this file is gone.
+
 * No dev_node_t (as of 2.6.35)
    There is no more need to fill out a "dev_node_t" structure.
 
diff --git a/drivers/ata/pata_pcmcia.c b/drivers/ata/pata_pcmcia.c
index 118c28e..3dcb2b1 100644
--- a/drivers/ata/pata_pcmcia.c
+++ b/drivers/ata/pata_pcmcia.c
@@ -34,7 +34,6 @@
 #include <linux/ata.h>
 #include <linux/libata.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index 6d34f40..eb085de 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -39,7 +39,6 @@
 #include <linux/skbuff.h>
 #include <linux/io.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 21e05fd..457b603 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -45,7 +45,6 @@
 #include <linux/device.h>
 #include <linux/firmware.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index 4ed7288..e7e0a17 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -41,7 +41,6 @@
 #include <asm/system.h>
 #include <asm/io.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index ef044d5..7c94aad 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -41,7 +41,6 @@
 #include <asm/system.h>
 #include <asm/io.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
diff --git a/drivers/char/pcmcia/cm4000_cs.c b/drivers/char/pcmcia/cm4000_cs.c
index e7956ac..a8be2a7 100644
--- a/drivers/char/pcmcia/cm4000_cs.c
+++ b/drivers/char/pcmcia/cm4000_cs.c
@@ -34,7 +34,6 @@
 #include <linux/uaccess.h>
 #include <linux/io.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/char/pcmcia/cm4040_cs.c b/drivers/char/pcmcia/cm4040_cs.c
index c0775c8..44adae9 100644
--- a/drivers/char/pcmcia/cm4040_cs.c
+++ b/drivers/char/pcmcia/cm4040_cs.c
@@ -29,7 +29,6 @@
 #include <asm/uaccess.h>
 #include <asm/io.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/char/pcmcia/ipwireless/main.h b/drivers/char/pcmcia/ipwireless/main.h
index 96d0ef3..c207be8 100644
--- a/drivers/char/pcmcia/ipwireless/main.h
+++ b/drivers/char/pcmcia/ipwireless/main.h
@@ -21,7 +21,6 @@
 #include <linux/sched.h>
 #include <linux/types.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/char/pcmcia/ipwireless/tty.h b/drivers/char/pcmcia/ipwireless/tty.h
index 4da6c20..3e163d4 100644
--- a/drivers/char/pcmcia/ipwireless/tty.h
+++ b/drivers/char/pcmcia/ipwireless/tty.h
@@ -21,7 +21,6 @@
 #include <linux/types.h>
 #include <linux/sched.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index 308903e..522992e 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -70,7 +70,6 @@
 #include <linux/workqueue.h>
 #include <linux/hdlc.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/ide/ide-cs.c b/drivers/ide/ide-cs.c
index 0b7815d..27dbab8 100644
--- a/drivers/ide/ide-cs.c
+++ b/drivers/ide/ide-cs.c
@@ -43,7 +43,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
index f410d0e..e804a01 100644
--- a/drivers/isdn/hardware/avm/avm_cs.c
+++ b/drivers/isdn/hardware/avm/avm_cs.c
@@ -20,7 +20,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index a80a761..49e141e 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -20,7 +20,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index 218927e..425deea 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -46,7 +46,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index 1f4feaa..5dbad96 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -46,7 +46,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index 5771955..d3fb1b7 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -27,7 +27,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/mmc/host/sdricoh_cs.c b/drivers/mmc/host/sdricoh_cs.c
index e7507af..7aa65bb 100644
--- a/drivers/mmc/host/sdricoh_cs.c
+++ b/drivers/mmc/host/sdricoh_cs.c
@@ -30,7 +30,6 @@
 #include <linux/ioport.h>
 #include <linux/scatterlist.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/mtd/maps/pcmciamtd.c b/drivers/mtd/maps/pcmciamtd.c
index e699e6a..7948816 100644
--- a/drivers/mtd/maps/pcmciamtd.c
+++ b/drivers/mtd/maps/pcmciamtd.c
@@ -16,7 +16,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 10ee106..e249b89 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -87,7 +87,6 @@ earlier 3Com products.
 #include <linux/bitops.h>
 #include <linux/mii.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index ce63c37..b0772df 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -41,7 +41,6 @@
 #include <linux/bitops.h>
 #include <linux/jiffies.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 33525bf..467fd4b 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -39,7 +39,6 @@
 #include <linux/mii.h>
 #include "../8390.h"
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
diff --git a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
index 5643f94..99957af 100644
--- a/drivers/net/pcmcia/com20020_cs.c
+++ b/drivers/net/pcmcia/com20020_cs.c
@@ -43,7 +43,6 @@
 #include <linux/arcdevice.h>
 #include <linux/com20020.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 7c27c50..95a991b 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -49,7 +49,6 @@
 #include <linux/ioport.h>
 #include <linux/crc32.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index 67ee985..c36dcd1 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -57,7 +57,6 @@
 #include <linux/trdevice.h>
 #include <linux/ibmtr.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 9b63dec..c0eacfa 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -146,7 +146,6 @@ Include Files
 #include <linux/ioport.h>
 #include <linux/bitops.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/cistpl.h>
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index bfdef72..db6dbda 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -42,7 +42,6 @@
 #include <linux/mii.h>
 #include "../8390.h"
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
@@ -113,8 +112,6 @@ static int setup_dma_config(struct pcmcia_device *link, int start_pg,
 
 static void pcnet_detach(struct pcmcia_device *p_dev);
 
-static dev_info_t dev_info = "pcnet_cs";
-
 /*====================================================================*/
 
 typedef struct hw_info_t {
@@ -956,7 +953,7 @@ static int pcnet_open(struct net_device *dev)
     set_misc_reg(dev);
 
     outb_p(0xFF, nic_base + EN0_ISR); /* Clear bogus intr. */
-    ret = request_irq(dev->irq, ei_irq_wrapper, IRQF_SHARED, dev_info, dev);
+    ret = request_irq(dev->irq, ei_irq_wrapper, IRQF_SHARED, dev->name, dev);
     if (ret)
 	    return ret;
 
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 307cd17..88f503a 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -44,7 +44,6 @@
 #include <linux/jiffies.h>
 #include <linux/firmware.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index b6c3644..a7662f0 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -82,7 +82,6 @@
 #include <linux/bitops.h>
 #include <linux/mii.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index 33bdc6a..9389ba0 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -32,7 +32,6 @@
 #include <linux/timer.h>
 #include <linux/netdevice.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index c2746fc..91ee74a 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -42,7 +42,6 @@
 #include <linux/moduleparam.h>
 #include <linux/device.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index 0e99b63..f71bc78 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -26,7 +26,6 @@
 #include <linux/ssb/ssb.h>
 #include <linux/slab.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 29b31a6..2f4b6d4 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -12,7 +12,6 @@
 #include <linux/wireless.h>
 #include <net/iw_handler.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
@@ -23,7 +22,7 @@
 #include "hostap_wlan.h"
 
 
-static dev_info_t dev_info = "hostap_cs";
+static char *dev_info = "hostap_cs";
 
 MODULE_AUTHOR("Jouni Malinen");
 MODULE_DESCRIPTION("Support for Intersil Prism2-based 802.11 wireless LAN "
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index 08e4e39..1d3a7e0 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -28,7 +28,6 @@
 #include <linux/firmware.h>
 #include <linux/netdevice.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wireless/orinoco/orinoco_cs.c
index b16d5db..41ca4f1 100644
--- a/drivers/net/wireless/orinoco/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco/orinoco_cs.c
@@ -17,7 +17,6 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/delay.h>
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/wireless/orinoco/spectrum_cs.c
index b51a9ad..cad30e4 100644
--- a/drivers/net/wireless/orinoco/spectrum_cs.c
+++ b/drivers/net/wireless/orinoco/spectrum_cs.c
@@ -25,7 +25,6 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/delay.h>
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index abff893..165beb6 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -46,7 +46,6 @@
 #include <linux/ethtool.h>
 #include <linux/ieee80211.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 376c6b9..35f431b 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -48,7 +48,6 @@
 
 #include <net/iw_handler.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
@@ -89,13 +88,6 @@
 static int wl3501_config(struct pcmcia_device *link);
 static void wl3501_release(struct pcmcia_device *link);
 
-/*
- * The dev_info variable is the "key" that is used to match up this
- * device driver with appropriate cards, through the card configuration
- * database.
- */
-static dev_info_t wl3501_dev_info = "wl3501_cs";
-
 static const struct {
 	int reg_domain;
 	int min, max, deflt;
@@ -1421,7 +1413,7 @@ static struct iw_statistics *wl3501_get_wireless_stats(struct net_device *dev)
 
 static void wl3501_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	strlcpy(info->driver, wl3501_dev_info, sizeof(info->driver));
+	strlcpy(info->driver, "wl3501_cs", sizeof(info->driver));
 }
 
 static const struct ethtool_ops ops = {
diff --git a/drivers/parport/parport_cs.c b/drivers/parport/parport_cs.c
index fd8cfe9..ee56fd6 100644
--- a/drivers/parport/parport_cs.c
+++ b/drivers/parport/parport_cs.c
@@ -48,7 +48,6 @@
 #include <linux/parport.h>
 #include <linux/parport_pc.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/pcmcia/au1000_generic.h b/drivers/pcmcia/au1000_generic.h
index a324d32..67530ce 100644
--- a/drivers/pcmcia/au1000_generic.h
+++ b/drivers/pcmcia/au1000_generic.h
@@ -23,7 +23,6 @@
 
 /* include the world */
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cistpl.h>
diff --git a/drivers/pcmcia/au1000_pb1x00.c b/drivers/pcmcia/au1000_pb1x00.c
index 5a979cb..807f2d7 100644
--- a/drivers/pcmcia/au1000_pb1x00.c
+++ b/drivers/pcmcia/au1000_pb1x00.c
@@ -31,11 +31,9 @@
 #include <linux/proc_fs.h>
 #include <linux/types.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cistpl.h>
-#include <pcmcia/bus_ops.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
diff --git a/drivers/pcmcia/cistpl.c b/drivers/pcmcia/cistpl.c
index 8844bc3..ba4a5ac 100644
--- a/drivers/pcmcia/cistpl.c
+++ b/drivers/pcmcia/cistpl.c
@@ -27,7 +27,6 @@
 #include <asm/byteorder.h>
 #include <asm/unaligned.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/pcmcia/cs.c b/drivers/pcmcia/cs.c
index efa30b8..2ec8ac9 100644
--- a/drivers/pcmcia/cs.c
+++ b/drivers/pcmcia/cs.c
@@ -32,7 +32,6 @@
 #include <asm/system.h>
 #include <asm/irq.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
diff --git a/drivers/pcmcia/db1xxx_ss.c b/drivers/pcmcia/db1xxx_ss.c
index 0f4cc3f..27575e6 100644
--- a/drivers/pcmcia/db1xxx_ss.c
+++ b/drivers/pcmcia/db1xxx_ss.c
@@ -29,7 +29,6 @@
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/ss.h>
 
 #include <asm/mach-au1x00/au1000.h>
diff --git a/drivers/pcmcia/ds.c b/drivers/pcmcia/ds.c
index 73aeaea..56933eb 100644
--- a/drivers/pcmcia/ds.c
+++ b/drivers/pcmcia/ds.c
@@ -26,7 +26,6 @@
 #include <linux/dma-mapping.h>
 #include <linux/slab.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/pcmcia/i82092.c b/drivers/pcmcia/i82092.c
index 3003bb3..05d0879 100644
--- a/drivers/pcmcia/i82092.c
+++ b/drivers/pcmcia/i82092.c
@@ -15,7 +15,6 @@
 #include <linux/interrupt.h>
 #include <linux/device.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cs.h>
 
diff --git a/drivers/pcmcia/i82365.c b/drivers/pcmcia/i82365.c
index 9e2a156..61746bd 100644
--- a/drivers/pcmcia/i82365.c
+++ b/drivers/pcmcia/i82365.c
@@ -50,7 +50,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cs.h>
 
diff --git a/drivers/pcmcia/m32r_cfc.c b/drivers/pcmcia/m32r_cfc.c
index 7e16ed8..24de499 100644
--- a/drivers/pcmcia/m32r_cfc.c
+++ b/drivers/pcmcia/m32r_cfc.c
@@ -26,7 +26,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cs.h>
 
diff --git a/drivers/pcmcia/m32r_pcc.c b/drivers/pcmcia/m32r_pcc.c
index 6c5c3f9..8e47238 100644
--- a/drivers/pcmcia/m32r_pcc.c
+++ b/drivers/pcmcia/m32r_pcc.c
@@ -27,7 +27,6 @@
 #include <asm/system.h>
 #include <asm/addrspace.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cs.h>
 
diff --git a/drivers/pcmcia/m8xx_pcmcia.c b/drivers/pcmcia/m8xx_pcmcia.c
index 25e5e30..f2f90a7 100644
--- a/drivers/pcmcia/m8xx_pcmcia.c
+++ b/drivers/pcmcia/m8xx_pcmcia.c
@@ -59,7 +59,6 @@
 #include <asm/irq.h>
 #include <asm/fs_pd.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/ss.h>
 
diff --git a/drivers/pcmcia/pcmcia_cis.c b/drivers/pcmcia/pcmcia_cis.c
index 4a65eaf..0ac54da 100644
--- a/drivers/pcmcia/pcmcia_cis.c
+++ b/drivers/pcmcia/pcmcia_cis.c
@@ -19,7 +19,6 @@
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ss.h>
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index a4cd9ad..2394de4 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -25,7 +25,6 @@
 
 #include <asm/irq.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
diff --git a/drivers/pcmcia/pd6729.c b/drivers/pcmcia/pd6729.c
index b61a136..b8a869a 100644
--- a/drivers/pcmcia/pd6729.c
+++ b/drivers/pcmcia/pd6729.c
@@ -17,7 +17,6 @@
 #include <linux/device.h>
 #include <linux/io.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cs.h>
 
diff --git a/drivers/pcmcia/pxa2xx_base.c b/drivers/pcmcia/pxa2xx_base.c
index df4532e..66c0225 100644
--- a/drivers/pcmcia/pxa2xx_base.c
+++ b/drivers/pcmcia/pxa2xx_base.c
@@ -32,7 +32,6 @@
 #include <mach/pxa2xx-regs.h>
 #include <asm/mach-types.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cistpl.h>
 
diff --git a/drivers/pcmcia/rsrc_iodyn.c b/drivers/pcmcia/rsrc_iodyn.c
index 6ed7bf1..3b1dce2 100644
--- a/drivers/pcmcia/rsrc_iodyn.c
+++ b/drivers/pcmcia/rsrc_iodyn.c
@@ -16,7 +16,6 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
diff --git a/drivers/pcmcia/rsrc_mgr.c b/drivers/pcmcia/rsrc_mgr.c
index b12ecf7..b433a79 100644
--- a/drivers/pcmcia/rsrc_mgr.c
+++ b/drivers/pcmcia/rsrc_mgr.c
@@ -16,7 +16,6 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
diff --git a/drivers/pcmcia/rsrc_nonstatic.c b/drivers/pcmcia/rsrc_nonstatic.c
index 13245a2..0cca08f 100644
--- a/drivers/pcmcia/rsrc_nonstatic.c
+++ b/drivers/pcmcia/rsrc_nonstatic.c
@@ -28,7 +28,6 @@
 
 #include <asm/irq.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
diff --git a/drivers/pcmcia/sa1100_generic.c b/drivers/pcmcia/sa1100_generic.c
index edbd8c4..e098514 100644
--- a/drivers/pcmcia/sa1100_generic.c
+++ b/drivers/pcmcia/sa1100_generic.c
@@ -35,7 +35,6 @@
 #include <linux/slab.h>
 #include <linux/platform_device.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/ss.h>
 
diff --git a/drivers/pcmcia/soc_common.h b/drivers/pcmcia/soc_common.h
index e40824c..3fba3a6 100644
--- a/drivers/pcmcia/soc_common.h
+++ b/drivers/pcmcia/soc_common.h
@@ -11,7 +11,6 @@
 
 /* include the world */
 #include <linux/cpufreq.h>
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cistpl.h>
diff --git a/drivers/pcmcia/socket_sysfs.c b/drivers/pcmcia/socket_sysfs.c
index 80e36bc..cb0d3ac 100644
--- a/drivers/pcmcia/socket_sysfs.c
+++ b/drivers/pcmcia/socket_sysfs.c
@@ -26,7 +26,6 @@
 #include <asm/system.h>
 #include <asm/irq.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
diff --git a/drivers/pcmcia/tcic.c b/drivers/pcmcia/tcic.c
index 56004a1..be0d841 100644
--- a/drivers/pcmcia/tcic.c
+++ b/drivers/pcmcia/tcic.c
@@ -49,7 +49,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/ss.h>
 #include "tcic.h"
diff --git a/drivers/pcmcia/xxs1500_ss.c b/drivers/pcmcia/xxs1500_ss.c
index 201ccfa..fa88c36 100644
--- a/drivers/pcmcia/xxs1500_ss.c
+++ b/drivers/pcmcia/xxs1500_ss.c
@@ -17,7 +17,6 @@
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cistpl.h>
diff --git a/drivers/pcmcia/yenta_socket.c b/drivers/pcmcia/yenta_socket.c
index f1d4137..414d9a6 100644
--- a/drivers/pcmcia/yenta_socket.c
+++ b/drivers/pcmcia/yenta_socket.c
@@ -19,7 +19,6 @@
 #include <linux/io.h>
 #include <linux/slab.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/ss.h>
 #include <pcmcia/cs.h>
 
diff --git a/drivers/scsi/pcmcia/aha152x_stub.c b/drivers/scsi/pcmcia/aha152x_stub.c
index 9d70aef..b07b53e 100644
--- a/drivers/scsi/pcmcia/aha152x_stub.c
+++ b/drivers/scsi/pcmcia/aha152x_stub.c
@@ -49,7 +49,6 @@
 #include <scsi/scsi_host.h>
 #include "aha152x.h"
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/scsi/pcmcia/fdomain_stub.c b/drivers/scsi/pcmcia/fdomain_stub.c
index 21b1411..ee04897 100644
--- a/drivers/scsi/pcmcia/fdomain_stub.c
+++ b/drivers/scsi/pcmcia/fdomain_stub.c
@@ -46,7 +46,6 @@
 #include <scsi/scsi_host.h>
 #include "fdomain.h"
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index 0f0e112..d414207 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -47,7 +47,6 @@
 #include <scsi/scsi.h>
 #include <scsi/scsi_ioctl.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/scsi/pcmcia/qlogic_stub.c b/drivers/scsi/pcmcia/qlogic_stub.c
index f0fc6ba..c1cf7f4 100644
--- a/drivers/scsi/pcmcia/qlogic_stub.c
+++ b/drivers/scsi/pcmcia/qlogic_stub.c
@@ -48,7 +48,6 @@
 #include <scsi/scsi_host.h>
 #include "../qlogicfas408.h"
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/scsi/pcmcia/sym53c500_cs.c b/drivers/scsi/pcmcia/sym53c500_cs.c
index a511641..bd79e45 100644
--- a/drivers/scsi/pcmcia/sym53c500_cs.c
+++ b/drivers/scsi/pcmcia/sym53c500_cs.c
@@ -71,7 +71,6 @@
 #include <scsi/scsi.h>
 #include <scsi/scsi_host.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index ab17c08..2b99c7b 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -45,7 +45,6 @@
 #include <asm/io.h>
 #include <asm/system.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index 51275aa..06f04b4 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -20,7 +20,6 @@
 #include <linux/mmc/sdio_func.h>
 #include <linux/slab.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/ssb/pcmcia.c b/drivers/ssb/pcmcia.c
index e72f404..2152030 100644
--- a/drivers/ssb/pcmcia.c
+++ b/drivers/ssb/pcmcia.c
@@ -13,7 +13,6 @@
 #include <linux/io.h>
 #include <linux/etherdevice.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
diff --git a/drivers/ssb/scan.c b/drivers/ssb/scan.c
index 0d6c028..9738cad 100644
--- a/drivers/ssb/scan.c
+++ b/drivers/ssb/scan.c
@@ -17,7 +17,6 @@
 #include <linux/pci.h>
 #include <linux/io.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/staging/comedi/drivers/cb_das16_cs.c b/drivers/staging/comedi/drivers/cb_das16_cs.c
index cfeb11f..acef29c 100644
--- a/drivers/staging/comedi/drivers/cb_das16_cs.c
+++ b/drivers/staging/comedi/drivers/cb_das16_cs.c
@@ -37,7 +37,6 @@ Status: experimental
 #include <linux/delay.h>
 #include <linux/pci.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/staging/comedi/drivers/das08_cs.c b/drivers/staging/comedi/drivers/das08_cs.c
index 8761a6d..3eddb7c 100644
--- a/drivers/staging/comedi/drivers/das08_cs.c
+++ b/drivers/staging/comedi/drivers/das08_cs.c
@@ -48,7 +48,6 @@ Command support does not exist, but could be added for this board.
 #include "das08.h"
 
 /* pcmcia includes */
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/staging/comedi/drivers/ni_daq_700.c b/drivers/staging/comedi/drivers/ni_daq_700.c
index 6ec77bf..f3c4d2f 100644
--- a/drivers/staging/comedi/drivers/ni_daq_700.c
+++ b/drivers/staging/comedi/drivers/ni_daq_700.c
@@ -47,7 +47,6 @@ IRQ is assigned but not used.
 
 #include <linux/ioport.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/staging/comedi/drivers/ni_daq_dio24.c b/drivers/staging/comedi/drivers/ni_daq_dio24.c
index e4865b1..f0c4367 100644
--- a/drivers/staging/comedi/drivers/ni_daq_dio24.c
+++ b/drivers/staging/comedi/drivers/ni_daq_dio24.c
@@ -48,7 +48,6 @@ the PCMCIA interface.
 
 #include "8255.h"
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/staging/comedi/drivers/ni_labpc_cs.c b/drivers/staging/comedi/drivers/ni_labpc_cs.c
index 163245e..1ee78f8 100644
--- a/drivers/staging/comedi/drivers/ni_labpc_cs.c
+++ b/drivers/staging/comedi/drivers/ni_labpc_cs.c
@@ -71,7 +71,6 @@ NI manuals:
 #include "comedi_fc.h"
 #include "ni_labpc.h"
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/staging/comedi/drivers/ni_mio_cs.c b/drivers/staging/comedi/drivers/ni_mio_cs.c
index 3a46f0c..0bce220 100644
--- a/drivers/staging/comedi/drivers/ni_mio_cs.c
+++ b/drivers/staging/comedi/drivers/ni_mio_cs.c
@@ -48,7 +48,6 @@ See the notes in the ni_atmio.o driver.
 #include "ni_stc.h"
 #include "8255.h"
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/staging/comedi/drivers/quatech_daqp_cs.c b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
index a91db6c..67c0fa6 100644
--- a/drivers/staging/comedi/drivers/quatech_daqp_cs.c
+++ b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
@@ -50,7 +50,6 @@ Devices: [Quatech] DAQP-208 (daqp), DAQP-308
 #include "../comedidev.h"
 #include <linux/semaphore.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/staging/wlags49_h2/wl_cs.c b/drivers/staging/wlags49_h2/wl_cs.c
index 10abd40..afe4575 100644
--- a/drivers/staging/wlags49_h2/wl_cs.c
+++ b/drivers/staging/wlags49_h2/wl_cs.c
@@ -83,7 +83,6 @@
 #include <linux/if_arp.h>
 #include <linux/ioport.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/staging/wlags49_h2/wl_internal.h b/drivers/staging/wlags49_h2/wl_internal.h
index d9a0ad0..02f0a20 100644
--- a/drivers/staging/wlags49_h2/wl_internal.h
+++ b/drivers/staging/wlags49_h2/wl_internal.h
@@ -69,7 +69,6 @@
  ******************************************************************************/
 #include <linux/version.h>
 #ifdef BUS_PCMCIA
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
diff --git a/drivers/telephony/ixj_pcmcia.c b/drivers/telephony/ixj_pcmcia.c
index 99cb224..f6c7e6f 100644
--- a/drivers/telephony/ixj_pcmcia.c
+++ b/drivers/telephony/ixj_pcmcia.c
@@ -8,7 +8,6 @@
 #include <linux/errno.h>	/* error codes */
 #include <linux/slab.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/drivers/usb/host/sl811_cs.c b/drivers/usb/host/sl811_cs.c
index 58cb73c..acb7e25 100644
--- a/drivers/usb/host/sl811_cs.c
+++ b/drivers/usb/host/sl811_cs.c
@@ -20,7 +20,6 @@
 #include <linux/ioport.h>
 #include <linux/platform_device.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
@@ -43,8 +42,6 @@ MODULE_LICENSE("GPL");
 /* VARIABLES                                                          */
 /*====================================================================*/
 
-static const char driver_name[DEV_NAME_LEN]  = "sl811_cs";
-
 typedef struct local_info_t {
 	struct pcmcia_device	*p_dev;
 } local_info_t;
@@ -246,7 +243,7 @@ MODULE_DEVICE_TABLE(pcmcia, sl811_ids);
 static struct pcmcia_driver sl811_cs_driver = {
 	.owner		= THIS_MODULE,
 	.drv		= {
-		.name	= (char *)driver_name,
+		.name	= "sl811_cs",
 	},
 	.probe		= sl811_cs_probe,
 	.remove		= sl811_cs_detach,
diff --git a/include/pcmcia/cistpl.h b/include/pcmcia/cistpl.h
index cfdd5af..1c5088c 100644
--- a/include/pcmcia/cistpl.h
+++ b/include/pcmcia/cistpl.h
@@ -15,6 +15,8 @@
 #ifndef _LINUX_CISTPL_H
 #define _LINUX_CISTPL_H
 
+typedef unsigned char cisdata_t;
+
 #define CISTPL_NULL		0x00
 #define CISTPL_DEVICE		0x01
 #define CISTPL_LONGLINK_CB	0x02
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
index c943c96..c78d9b1 100644
--- a/include/pcmcia/cs.h
+++ b/include/pcmcia/cs.h
@@ -43,14 +43,6 @@ typedef struct conf_reg_t {
 #define CV_COPY_VALUE		0x08
 #define CV_EXT_STATUS		0x10
 
-/* For GetFirst/NextClient */
-typedef struct client_req_t {
-    socket_t	Socket;
-    u_int	Attributes;
-} client_req_t;
-
-#define CLIENT_THIS_SOCKET	0x01
-
 /* ModifyConfiguration */
 typedef struct modconf_t {
     u_int	Attributes;
@@ -133,7 +125,7 @@ typedef struct io_req_t {
 /* For GetMemPage, MapMemPage */
 typedef struct memreq_t {
     u_int	CardOffset;
-    page_t	Page;
+    u_short	Page;
 } memreq_t;
 
 /* For ModifyWindow */
diff --git a/include/pcmcia/cs_types.h b/include/pcmcia/cs_types.h
deleted file mode 100644
index f5e3b83..0000000
--- a/include/pcmcia/cs_types.h
+++ /dev/null
@@ -1,40 +0,0 @@
-/*
- * cs_types.h
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- *
- * The initial developer of the original code is David A. Hinds
- * <dahinds@users.sourceforge.net>.  Portions created by David A. Hinds
- * are Copyright (C) 1999 David A. Hinds.  All Rights Reserved.
- *
- * (C) 1999             David A. Hinds
- */
-
-#ifndef _LINUX_CS_TYPES_H
-#define _LINUX_CS_TYPES_H
-
-#ifdef __KERNEL__
-#include <linux/types.h>
-#else
-#include <sys/types.h>
-#endif
-
-typedef u_short	socket_t;
-typedef u_int	event_t;
-typedef u_char	cisdata_t;
-typedef u_short	page_t;
-
-typedef unsigned long window_handle_t;
-
-struct region_t;
-typedef struct region_t *memory_handle_t;
-
-#ifndef DEV_NAME_LEN
-#define DEV_NAME_LEN 32
-#endif
-
-typedef char dev_info_t[DEV_NAME_LEN];
-
-#endif /* _LINUX_CS_TYPES_H */
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index 7d7721e..e614aa0 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -20,7 +20,6 @@
 #include <linux/mod_devicetable.h>
 #endif
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/device_id.h>
 
 #ifdef __KERNEL__
@@ -37,6 +36,8 @@ struct pcmcia_device;
 struct config_t;
 struct net_device;
 
+typedef unsigned long window_handle_t;
+
 /* dynamic device IDs for PCMCIA device drivers. See
  * Documentation/pcmcia/driver.txt for details.
 */
diff --git a/include/pcmcia/ss.h b/include/pcmcia/ss.h
index aeac271..626b63c 100644
--- a/include/pcmcia/ss.h
+++ b/include/pcmcia/ss.h
@@ -19,7 +19,6 @@
 #include <linux/sched.h>	/* task_struct, completion */
 #include <linux/mutex.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #ifdef CONFIG_CARDBUS
 #include <linux/pci.h>
diff --git a/sound/pcmcia/pdaudiocf/pdaudiocf.h b/sound/pcmcia/pdaudiocf/pdaudiocf.h
index a0a7ec6..5cc3e45 100644
--- a/sound/pcmcia/pdaudiocf/pdaudiocf.h
+++ b/sound/pcmcia/pdaudiocf/pdaudiocf.h
@@ -24,7 +24,6 @@
 #include <sound/pcm.h>
 #include <asm/io.h>
 #include <linux/interrupt.h>
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
diff --git a/sound/pcmcia/vx/vxpocket.h b/sound/pcmcia/vx/vxpocket.h
index ea4df16..d911066 100644
--- a/sound/pcmcia/vx/vxpocket.h
+++ b/sound/pcmcia/vx/vxpocket.h
@@ -23,7 +23,6 @@
 
 #include <sound/vx_core.h>
 
-#include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
-- 
1.7.0.4

