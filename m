From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [PATCH 2.4.26] add prism54 to 2.4 tree
Date: Wed, 21 Jul 2004 05:34:06 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040721093406.GB9141@ruslug.rutgers.edu>
References: <20040715005140.GH14482@ruslug.rutgers.edu>
	<20040720132453.GA2348@dmt.cyclades>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1706733925=="
Cc: Netdev <netdev@oss.sgi.com>, prism54-devel@prism54.org,
	jgarzik@pobox.com
Return-path: <prism54-devel-bounces@prism54.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
In-Reply-To: <20040720132453.GA2348@dmt.cyclades>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============1706733925==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="V0207lvV8h4k8FAm"
Content-Disposition: inline


--V0207lvV8h4k8FAm
Content-Type: multipart/mixed; boundary="fUYQa+Pmc3FrFX/N"
Content-Disposition: inline


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 20, 2004 at 10:24:53AM -0300, Marcelo Tosatti wrote:
> On Wed, Jul 14, 2004 at 08:51:40PM -0400, Luis R. Rodriguez wrote:
> >=20
> > Marcelo,
> >=20
> > Attached patch adds prism54 to 2.4 tree. This patch applies cleanly to
> > 2.4.27-rc3 as well.
>=20
> Hi Luis,=20
>=20
> This looks fine for inclusion on 2.4.28-pre, after Jeff/others take a loo=
k=20
> at it.=20

Marcelo,

The attached patch catches a couple of recent changes which are important.
Please consider this patch as *the* candidate for inclusion of prism54 onto=
 2.4.=20
Jeff may take a look at it but all this has already been revised a lot
so I wouldn't expect much more revising going on except for two new
patches pending to sync our trees.

Jeff,

This patch has exactly what we had + two pending patches Margit just
sent in. Can you give the green light for Marcelo to include this on
2.4?

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="patch-2.4-prism54-cvs-latest.diff"
Content-Transfer-Encoding: quoted-printable

--- linux-2.4.26/Documentation/Configure.help	2004-04-14 13:05:24.000000000=
 +0000
+++ linux-2.4.26-prism54/Documentation/Configure.help	2004-07-21 09:00:04.0=
00000000 +0000
@@ -9968,6 +9968,49 @@
   compile it as a module, say M here and read
   <file:Documentation/modules.txt>.
=20
+Intersil 802.11(a/b/g) Prism GT/Duette/Indigo support
+CONFIG_PRISM54
+  Enable PCI and Cardbus support for the following chipset based cards:
+
+  ISL3880 - Prism GT		802.11 b/g
+  ISL3877 - Prism Indigo	802.11 a
+  ISL3890 - Prism Duette	802.11 a/b/g
+ =20
+  For a complete list of supported cards visit <http://prism54.org>.
+  Here is the latest confirmed list of supported cards:
+
+  3com OfficeConnect 11g Cardbus Card aka 3CRWE154G72
+  Allnet ALL0271 PCI Card
+  Compex WL54G Cardbus Card
+  Corega CG-WLCB54GT Cardbus Card
+  D-Link Air Plus Xtreme G A1 Cardbus Card aka DWL-g650
+  I-O Data WN-G54/CB Cardbus Card
+  Kobishi XG-300 aka Z-Com Cardbus Card
+  Netgear WG511 Cardbus Card
+  Ovislink WL-5400PCI PCI Card
+  Peabird WLG-PCI PCI Card
+  Sitecom WL-100i Cardbus Card
+  Sitecom WL-110i PCI Card
+  SMC2802W - EZ Connect g 2.4GHz 54 Mbps Wireless PCI Card
+  SMC2835W - EZ Connect g 2.4GHz 54 Mbps Wireless Cardbus Card
+  Z-Com XG-900 PCI Card
+  Zyxel G-100 Cardbus Card
+
+  If you enable this, you require a firmware file as well.
+  You will need to copy this to /usr/lib/hotplug/firmware/isl3890.
+  You can get this non-GPL'd firmware file from the Prism54 project page:
+  <http://prism54.org>.
+  You will also need the /etc/hotplug/firmware.agent script from
+  a current hotplug package.
+
+
+  Note: You need a motherboard with DMA support to use any of these cards=
=20
+ =20
+  If you want to compile the driver as a module ( =3D code which can be
+  inserted in and removed from the running kernel whenever you want),
+  say M here and read <file:Documentation/modules.txt>.  The module
+  will be called prism54.o.
+
 Aironet 4500/4800 PROC interface
 CONFIG_AIRONET4500_PROC
   If you say Y here (and to the "/proc file system" below), you will
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/C=
onfig.in linux-2.4.26-prism54/drivers/net/wireless/Config.in
--- linux-2.4.26/drivers/net/wireless/Config.in	2004-04-14 13:05:30.0000000=
00 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/Config.in	2004-07-21 09:00:04=
.000000000 +0000
@@ -27,6 +27,15 @@
    dep_tristate '  Atmel at76c502/at76c504 PCMCIA cards' CONFIG_PCMCIA_ATM=
EL $CONFIG_FW_LOADER
 fi
=20
+# If PCI enabled, allow for prism54 driver. CONFIG_FW_LOADER required
+comment 'Prism54 PCI/PCMCIA GT/Duette Driver - 802.11(a/b/g)'
+dep_tristate 'Intersil Prism GT/Duette/Indigo PCI/PCMCIA' CONFIG_PRISM54 $=
CONFIG_EXPERIMENTAL $CONFIG_PCI $CONFIG_HOTPLUG
+if [ "$CONFIG_PRISM54" !=3D "n" ]; then
+ if [ "$CONFIG_FW_LOADER" !=3D "y" ]; then
+  define_tristate CONFIG_FW_LOADER $CONFIG_PRISM54
+ fi
+fi
+
 # yes, this works even when no drivers are selected
 if [ "$CONFIG_ISA" =3D "y" -o "$CONFIG_PCI" =3D "y" -o \
      "$CONFIG_ALL_PPC" =3D "y" -o "$CONFIG_PCMCIA" !=3D "n" ]; then
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/M=
akefile linux-2.4.26-prism54/drivers/net/wireless/Makefile
--- linux-2.4.26/drivers/net/wireless/Makefile	2004-04-14 13:05:30.00000000=
0 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/Makefile	2004-07-21 09:00:04.=
000000000 +0000
@@ -25,4 +25,9 @@
 obj-$(CONFIG_AIRO_CS)		+=3D airo_cs.o airo.o
 obj-$(CONFIG_PCMCIA_ATMEL)	+=3D atmel_cs.o atmel.o
=20
+ifeq ($(CONFIG_PRISM54),y)
+obj-$(CONFIG_PRISM54)		+=3D prism54/prism54.o
+endif
+subdir-$(CONFIG_PRISM54)	+=3D prism54
+
 include $(TOPDIR)/Rules.make
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/p=
rism54/Makefile linux-2.4.26-prism54/drivers/net/wireless/prism54/Makefile
--- linux-2.4.26/drivers/net/wireless/prism54/Makefile	1970-01-01 00:00:00.=
000000000 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/prism54/Makefile	2004-07-21 0=
9:00:04.000000000 +0000
@@ -0,0 +1,12 @@
+
+O_TARGET :=3D prism54.o
+
+EXTRA_CFLAGS +=3D -DPRISM54_COMPAT24
+
+obj-y		:=3D isl_38xx.o islpci_dev.o islpci_eth.o \
+		   islpci_mgt.o islpci_hotplug.o isl_ioctl.o \
+		   oid_mgt.o
+
+obj-m		+=3D prism54.o
+
+include $(TOPDIR)/Rules.make
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/p=
rism54/isl_38xx.c linux-2.4.26-prism54/drivers/net/wireless/prism54/isl_38x=
x.c
--- linux-2.4.26/drivers/net/wireless/prism54/isl_38xx.c	1970-01-01 00:00:0=
0.000000000 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/prism54/isl_38xx.c	2004-07-21=
 09:00:04.000000000 +0000
@@ -0,0 +1,267 @@
+/*
+ * =20
+ *  Copyright (C) 2002 Intersil Americas Inc.
+ *  Copyright (C) 2003-2004 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>_
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ */
+
+#define __KERNEL_SYSCALLS__
+
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/delay.h>
+
+#include <asm/uaccess.h>
+#include <asm/io.h>
+
+#include "prismcompat.h"
+#include "isl_38xx.h"
+#include "islpci_dev.h"
+#include "islpci_mgt.h"
+
+/*************************************************************************=
*****
+    Device Interface & Control functions
+**************************************************************************=
****/
+
+/**
+ * isl38xx_disable_interrupts - disable all interrupts
+ * @device: pci memory base address
+ *
+ *  Instructs the device to disable all interrupt reporting by asserting=
=20
+ *  the IRQ line. New events may still show up in the interrupt identifica=
tion
+ *  register located at offset %ISL38XX_INT_IDENT_REG.
+ */
+void
+isl38xx_disable_interrupts(void *device)
+{
+	isl38xx_w32_flush(device, 0x00000000, ISL38XX_INT_EN_REG);
+	udelay(ISL38XX_WRITEIO_DELAY);
+}
+
+void
+isl38xx_handle_sleep_request(isl38xx_control_block *control_block,
+			     int *powerstate, void *device_base)
+{
+	/* device requests to go into sleep mode
+	 * check whether the transmit queues for data and management are empty */
+	if (isl38xx_in_queue(control_block, ISL38XX_CB_TX_DATA_LQ))
+		/* data tx queue not empty */
+		return;
+
+	if (isl38xx_in_queue(control_block, ISL38XX_CB_TX_MGMTQ))
+		/* management tx queue not empty */
+		return;
+
+	/* check also whether received frames are pending */
+	if (isl38xx_in_queue(control_block, ISL38XX_CB_RX_DATA_LQ))
+		/* data rx queue not empty */
+		return;
+
+	if (isl38xx_in_queue(control_block, ISL38XX_CB_RX_MGMTQ))
+		/* management rx queue not empty */
+		return;
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	DEBUG(SHOW_TRACING, "Device going to sleep mode\n");
+#endif
+
+	/* all queues are empty, allow the device to go into sleep mode */
+	*powerstate =3D ISL38XX_PSM_POWERSAVE_STATE;
+
+	/* assert the Sleep interrupt in the Device Interrupt Register */
+	isl38xx_w32_flush(device_base, ISL38XX_DEV_INT_SLEEP,
+			  ISL38XX_DEV_INT_REG);
+	udelay(ISL38XX_WRITEIO_DELAY);
+}
+
+void
+isl38xx_handle_wakeup(isl38xx_control_block *control_block,
+		      int *powerstate, void *device_base)
+{
+	/* device is in active state, update the powerstate flag */
+	*powerstate =3D ISL38XX_PSM_ACTIVE_STATE;
+
+	/* now check whether there are frames pending for the card */
+	if (!isl38xx_in_queue(control_block, ISL38XX_CB_TX_DATA_LQ)
+	    && !isl38xx_in_queue(control_block, ISL38XX_CB_TX_MGMTQ))
+		return;
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	DEBUG(SHOW_ANYTHING, "Wake up handler trigger the device\n");
+#endif
+
+	/* either data or management transmit queue has a frame pending
+	 * trigger the device by setting the Update bit in the Device Int reg */
+	isl38xx_w32_flush(device_base, ISL38XX_DEV_INT_UPDATE,
+			  ISL38XX_DEV_INT_REG);
+	udelay(ISL38XX_WRITEIO_DELAY);
+}
+
+void
+isl38xx_trigger_device(int asleep, void *device_base)
+{
+	struct timeval current_time;
+	u32 reg, counter =3D 0;
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	DEBUG(SHOW_FUNCTION_CALLS, "isl38xx trigger device\n");
+#endif
+
+	/* check whether the device is in power save mode */
+	if (asleep) {
+		/* device is in powersave, trigger the device for wakeup */
+#if VERBOSE > SHOW_ERROR_MESSAGES
+		do_gettimeofday(&current_time);
+		DEBUG(SHOW_TRACING, "%08li.%08li Device wakeup triggered\n",
+		      current_time.tv_sec, current_time.tv_usec);
+#endif
+
+		DEBUG(SHOW_TRACING, "%08li.%08li Device register read %08x\n",
+		      current_time.tv_sec, current_time.tv_usec,
+		      readl(device_base + ISL38XX_CTRL_STAT_REG));
+		udelay(ISL38XX_WRITEIO_DELAY);
+
+		if (reg =3D readl(device_base + ISL38XX_INT_IDENT_REG),
+		    reg =3D=3D 0xabadface) {
+#if VERBOSE > SHOW_ERROR_MESSAGES
+			do_gettimeofday(&current_time);
+			DEBUG(SHOW_TRACING,
+			      "%08li.%08li Device register abadface\n",
+			      current_time.tv_sec, current_time.tv_usec);
+#endif
+			/* read the Device Status Register until Sleepmode bit is set */
+			while (reg =3D readl(device_base + ISL38XX_CTRL_STAT_REG),
+			       (reg & ISL38XX_CTRL_STAT_SLEEPMODE) =3D=3D 0) {
+				udelay(ISL38XX_WRITEIO_DELAY);
+				counter++;
+			}
+
+			DEBUG(SHOW_TRACING,
+			      "%08li.%08li Device register read %08x\n",
+			      current_time.tv_sec, current_time.tv_usec,
+			      readl(device_base + ISL38XX_CTRL_STAT_REG));
+			udelay(ISL38XX_WRITEIO_DELAY);
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+			do_gettimeofday(&current_time);
+			DEBUG(SHOW_TRACING,
+			      "%08li.%08li Device asleep counter %i\n",
+			      current_time.tv_sec, current_time.tv_usec,
+			      counter);
+#endif
+		}
+		/* assert the Wakeup interrupt in the Device Interrupt Register */
+		isl38xx_w32_flush(device_base, ISL38XX_DEV_INT_WAKEUP,
+				  ISL38XX_DEV_INT_REG);
+		udelay(ISL38XX_WRITEIO_DELAY);
+
+		/* perform another read on the Device Status Register */
+		reg =3D readl(device_base + ISL38XX_CTRL_STAT_REG);
+		udelay(ISL38XX_WRITEIO_DELAY);
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+		do_gettimeofday(&current_time);
+		DEBUG(SHOW_TRACING, "%08li.%08li Device register read %08x\n",
+		      current_time.tv_sec, current_time.tv_usec, reg);
+#endif
+	} else {
+		/* device is (still) awake  */
+#if VERBOSE > SHOW_ERROR_MESSAGES
+		DEBUG(SHOW_TRACING, "Device is in active state\n");
+#endif
+		/* trigger the device by setting the Update bit in the Device Int reg */
+
+		isl38xx_w32_flush(device_base, ISL38XX_DEV_INT_UPDATE,
+				  ISL38XX_DEV_INT_REG);
+		udelay(ISL38XX_WRITEIO_DELAY);
+	}
+}
+
+void
+isl38xx_interface_reset(void *device_base, dma_addr_t host_address)
+{
+	u32 reg;
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	DEBUG(SHOW_FUNCTION_CALLS, "isl38xx_interface_reset \n");
+#endif
+
+	/* load the address of the control block in the device */
+	isl38xx_w32_flush(device_base, host_address, ISL38XX_CTRL_BLK_BASE_REG);
+	udelay(ISL38XX_WRITEIO_DELAY);
+
+	/* set the reset bit in the Device Interrupt Register */
+	isl38xx_w32_flush(device_base, ISL38XX_DEV_INT_RESET,
+			  ISL38XX_DEV_INT_REG);
+	udelay(ISL38XX_WRITEIO_DELAY);
+
+	/* enable the interrupt for detecting initialization */
+
+	/* Note: Do not enable other interrupts here. We want the
+	 * device to have come up first 100% before allowing any other=20
+	 * interrupts. */
+	reg =3D ISL38XX_INT_IDENT_INIT;
+
+	isl38xx_w32_flush(device_base, reg, ISL38XX_INT_EN_REG);
+	udelay(ISL38XX_WRITEIO_DELAY);  /* allow complete full reset */
+}
+
+void
+isl38xx_enable_common_interrupts(void *device_base) {
+	u32 reg;
+	reg =3D ( ISL38XX_INT_IDENT_UPDATE |=20
+			ISL38XX_INT_IDENT_SLEEP | ISL38XX_INT_IDENT_WAKEUP);
+	isl38xx_w32_flush(device_base, reg, ISL38XX_INT_EN_REG);
+	udelay(ISL38XX_WRITEIO_DELAY);
+}
+
+int
+isl38xx_in_queue(isl38xx_control_block *cb, int queue)
+{
+	const s32 delta =3D (le32_to_cpu(cb->driver_curr_frag[queue]) -
+			   le32_to_cpu(cb->device_curr_frag[queue]));
+
+	/* determine the amount of fragments in the queue depending on the type
+	 * of the queue, either transmit or receive */
+
+	BUG_ON(delta < 0);	/* driver ptr must be ahead of device ptr */
+
+	switch (queue) {
+		/* send queues */
+	case ISL38XX_CB_TX_MGMTQ:
+		BUG_ON(delta > ISL38XX_CB_MGMT_QSIZE);
+	case ISL38XX_CB_TX_DATA_LQ:
+	case ISL38XX_CB_TX_DATA_HQ:
+		BUG_ON(delta > ISL38XX_CB_TX_QSIZE);
+		return delta;
+		break;
+
+		/* receive queues */
+	case ISL38XX_CB_RX_MGMTQ:
+		BUG_ON(delta > ISL38XX_CB_MGMT_QSIZE);
+		return ISL38XX_CB_MGMT_QSIZE - delta;
+		break;
+
+	case ISL38XX_CB_RX_DATA_LQ:
+	case ISL38XX_CB_RX_DATA_HQ:
+		BUG_ON(delta > ISL38XX_CB_RX_QSIZE);
+		return ISL38XX_CB_RX_QSIZE - delta;
+		break;
+	}
+	BUG();
+	return 0;
+}
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/p=
rism54/isl_38xx.h linux-2.4.26-prism54/drivers/net/wireless/prism54/isl_38x=
x.h
--- linux-2.4.26/drivers/net/wireless/prism54/isl_38xx.h	1970-01-01 00:00:0=
0.000000000 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/prism54/isl_38xx.h	2004-07-21=
 09:00:04.000000000 +0000
@@ -0,0 +1,169 @@
+/*
+ * =20
+ *  Copyright (C) 2002 Intersil Americas Inc.
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ */
+
+#ifndef _ISL_38XX_H
+#define _ISL_38XX_H
+
+#include <linux/version.h>
+#include <asm/io.h>
+#include <asm/byteorder.h>
+
+#define ISL38XX_CB_RX_QSIZE                     8
+#define ISL38XX_CB_TX_QSIZE                     32
+
+/* ISL38XX Access Point Specific definitions */
+#define ISL38XX_MAX_WDS_LINKS                   8
+
+/* ISL38xx Client Specific definitions */
+#define ISL38XX_PSM_ACTIVE_STATE                0
+#define ISL38XX_PSM_POWERSAVE_STATE             1
+
+/* ISL38XX Host Interface Definitions */
+#define ISL38XX_PCI_MEM_SIZE                    0x02000
+#define ISL38XX_MEMORY_WINDOW_SIZE              0x01000
+#define ISL38XX_DEV_FIRMWARE_ADDRES             0x20000
+#define ISL38XX_WRITEIO_DELAY                   10	/* in us */
+#define ISL38XX_RESET_DELAY                     50	/* in ms */
+#define ISL38XX_WAIT_CYCLE                      10	/* in 10ms */
+#define ISL38XX_MAX_WAIT_CYCLES                 10
+
+/* PCI Memory Area */
+#define ISL38XX_HARDWARE_REG                    0x0000
+#define ISL38XX_CARDBUS_CIS                     0x0800
+#define ISL38XX_DIRECT_MEM_WIN                  0x1000
+
+/* Hardware registers */
+#define ISL38XX_DEV_INT_REG                     0x0000
+#define ISL38XX_INT_IDENT_REG                   0x0010
+#define ISL38XX_INT_ACK_REG                     0x0014
+#define ISL38XX_INT_EN_REG                      0x0018
+#define ISL38XX_GEN_PURP_COM_REG_1              0x0020
+#define ISL38XX_GEN_PURP_COM_REG_2              0x0024
+#define ISL38XX_CTRL_BLK_BASE_REG               ISL38XX_GEN_PURP_COM_REG_1
+#define ISL38XX_DIR_MEM_BASE_REG                0x0030
+#define ISL38XX_CTRL_STAT_REG                   0x0078
+
+/* High end mobos queue up pci writes, the following
+ * is used to "read" from after a write to force flush */
+#define ISL38XX_PCI_POSTING_FLUSH		ISL38XX_INT_EN_REG
+
+/**
+ * isl38xx_w32_flush - PCI iomem write helper
+ * @base: (host) memory base address of the device
+ * @val: 32bit value (host order) to write
+ * @offset: byte offset into @base to write value to
+ *=20
+ *  This helper takes care of writing a 32bit datum to the
+ *  specified offset into the device's pci memory space, and making sure=
=20
+ *  the pci memory buffers get flushed by performing one harmless read=20
+ *  from the %ISL38XX_PCI_POSTING_FLUSH offset.
+ */
+static inline void
+isl38xx_w32_flush(void *base, u32 val, unsigned long offset)
+{
+	writel(val, base + offset);
+	(void) readl(base + ISL38XX_PCI_POSTING_FLUSH);
+}
+
+/* Device Interrupt register bits */
+#define ISL38XX_DEV_INT_RESET                   0x0001
+#define ISL38XX_DEV_INT_UPDATE                  0x0002
+#define ISL38XX_DEV_INT_WAKEUP                  0x0008
+#define ISL38XX_DEV_INT_SLEEP                   0x0010
+
+/* Interrupt Identification/Acknowledge/Enable register bits */
+#define ISL38XX_INT_IDENT_UPDATE                0x0002
+#define ISL38XX_INT_IDENT_INIT                  0x0004
+#define ISL38XX_INT_IDENT_WAKEUP                0x0008
+#define ISL38XX_INT_IDENT_SLEEP                 0x0010
+#define ISL38XX_INT_SOURCES                     0x001E
+
+/* Control/Status register bits */
+#define ISL38XX_CTRL_STAT_SLEEPMODE             0x00000200
+#define	ISL38XX_CTRL_STAT_CLKRUN		0x00800000
+#define ISL38XX_CTRL_STAT_RESET                 0x10000000
+#define ISL38XX_CTRL_STAT_RAMBOOT               0x20000000
+#define ISL38XX_CTRL_STAT_STARTHALTED           0x40000000
+#define ISL38XX_CTRL_STAT_HOST_OVERRIDE         0x80000000
+
+/* Control Block definitions */
+#define ISL38XX_CB_RX_DATA_LQ                   0
+#define ISL38XX_CB_TX_DATA_LQ                   1
+#define ISL38XX_CB_RX_DATA_HQ                   2
+#define ISL38XX_CB_TX_DATA_HQ                   3
+#define ISL38XX_CB_RX_MGMTQ                     4
+#define ISL38XX_CB_TX_MGMTQ                     5
+#define ISL38XX_CB_QCOUNT                       6
+#define ISL38XX_CB_MGMT_QSIZE                   4
+#define ISL38XX_MIN_QTHRESHOLD                  4	/* fragments */
+
+/* Memory Manager definitions */
+#define MGMT_FRAME_SIZE                         1500	/* >=3D size struct o=
bj_bsslist */
+#define MGMT_TX_FRAME_COUNT                     24	/* max 4 + spare 4 + 8 =
init */
+#define MGMT_RX_FRAME_COUNT                     24	/* 4*4 + spare 8 */
+#define MGMT_FRAME_COUNT                        (MGMT_TX_FRAME_COUNT + MGM=
T_RX_FRAME_COUNT)
+#define CONTROL_BLOCK_SIZE                      1024	/* should be enough */
+#define PSM_FRAME_SIZE                          1536
+#define PSM_MINIMAL_STATION_COUNT               64
+#define PSM_FRAME_COUNT                         PSM_MINIMAL_STATION_COUNT
+#define PSM_BUFFER_SIZE                         PSM_FRAME_SIZE * PSM_FRAME=
_COUNT
+#define MAX_TRAP_RX_QUEUE                       4
+#define HOST_MEM_BLOCK                          CONTROL_BLOCK_SIZE + PSM_B=
UFFER_SIZE
+
+/* Fragment package definitions */
+#define FRAGMENT_FLAG_MF                        0x0001
+#define MAX_FRAGMENT_SIZE                       1536
+
+/* In monitor mode frames have a header. I don't know exactly how big those
+ * frame can be but I've never seen any frame bigger than 1584... :
+ */
+#define MAX_FRAGMENT_SIZE_RX	                1600
+
+typedef struct {
+	u32 address;		/* physical address on host */
+	u16 size;		/* packet size */
+	u16 flags;		/* set of bit-wise flags */
+} isl38xx_fragment;
+
+struct isl38xx_cb {
+	u32 driver_curr_frag[ISL38XX_CB_QCOUNT];
+	u32 device_curr_frag[ISL38XX_CB_QCOUNT];
+	isl38xx_fragment rx_data_low[ISL38XX_CB_RX_QSIZE];
+	isl38xx_fragment tx_data_low[ISL38XX_CB_TX_QSIZE];
+	isl38xx_fragment rx_data_high[ISL38XX_CB_RX_QSIZE];
+	isl38xx_fragment tx_data_high[ISL38XX_CB_TX_QSIZE];
+	isl38xx_fragment rx_data_mgmt[ISL38XX_CB_MGMT_QSIZE];
+	isl38xx_fragment tx_data_mgmt[ISL38XX_CB_MGMT_QSIZE];
+};
+
+typedef struct isl38xx_cb isl38xx_control_block;
+
+/* determine number of entries currently in queue */
+int isl38xx_in_queue(isl38xx_control_block *cb, int queue);
+
+void isl38xx_disable_interrupts(void *);
+void isl38xx_enable_common_interrupts(void *);
+
+void isl38xx_handle_sleep_request(isl38xx_control_block *, int *,
+				  void *);
+void isl38xx_handle_wakeup(isl38xx_control_block *, int *, void *);
+void isl38xx_trigger_device(int, void *);
+void isl38xx_interface_reset(void *, dma_addr_t);
+
+#endif				/* _ISL_38XX_H */
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/p=
rism54/isl_ioctl.c linux-2.4.26-prism54/drivers/net/wireless/prism54/isl_io=
ctl.c
--- linux-2.4.26/drivers/net/wireless/prism54/isl_ioctl.c	1970-01-01 00:00:=
00.000000000 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/prism54/isl_ioctl.c	2004-07-2=
1 09:00:04.000000000 +0000
@@ -0,0 +1,2261 @@
+/*
+ * =20
+ *  Copyright (C) 2002 Intersil Americas Inc.
+ *            (C) 2003,2004 Aurelien Alleaume <slts@free.fr>
+ *            (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
+ *            (C) 2003 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ */
+
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/if_arp.h>
+#include <linux/pci.h>
+
+#include <asm/uaccess.h>
+
+#include "prismcompat.h"
+#include "isl_ioctl.h"
+#include "islpci_mgt.h"
+#include "isl_oid.h"		/* additional types and defs for isl38xx fw */
+#include "oid_mgt.h"
+
+#include <net/iw_handler.h>	/* New driver API */
+
+static int init_mode =3D CARD_DEFAULT_IW_MODE;
+static int init_channel =3D CARD_DEFAULT_CHANNEL;
+static int init_wep =3D CARD_DEFAULT_WEP;
+static int init_filter =3D CARD_DEFAULT_FILTER;
+static int init_authen =3D CARD_DEFAULT_AUTHEN;
+static int init_dot1x =3D CARD_DEFAULT_DOT1X;
+static int init_conformance =3D CARD_DEFAULT_CONFORMANCE;
+static int init_mlme =3D CARD_DEFAULT_MLME_MODE;
+
+module_param(init_mode, int, 0);
+MODULE_PARM_DESC(init_mode,
+		 "Set card mode:\n0: Auto\n1: Ad-Hoc\n2: Managed Client (Default)\n3: Ma=
ster / Access Point\n4: Repeater (Not supported yet)\n5: Secondary (Not sup=
ported yet)\n6: Monitor");
+
+module_param(init_channel, int, 0);
+MODULE_PARM_DESC(init_channel,
+		 "Check `iwpriv ethx channel` for available channels");
+
+module_param(init_wep, int, 0);
+module_param(init_filter, int, 0);
+
+module_param(init_authen, int, 0);
+MODULE_PARM_DESC(init_authen,
+		 "Authentication method. Can be of seven types:\n0 0x0000: None\n1 0x000=
1: DOT11_AUTH_OS (Default)\n2 0x0002: DOT11_AUTH_SK\n3 0x0003: DOT11_AUTH_B=
OTH");
+
+module_param(init_dot1x, int, 0);
+MODULE_PARM_DESC(init_dot1x,
+		 "\n0: None/not set	(Default)\n1: DOT11_DOT1X_AUTHENABLED\n2: DOT11_DOT1=
X_KEYTXENABLED");
+
+module_param(init_mlme, int, 0);
+MODULE_PARM_DESC(init_mlme,
+		 "Sets the MAC layer management entity (MLME) mode of operation,\n0: DOT=
11_MLME_AUTO (Default)\n1: DOT11_MLME_INTERMEDIATE\n2: DOT11_MLME_EXTENDED"=
);
+
+/**
+ * prism54_mib_mode_helper - MIB change mode helper function
+ * @mib: the &struct islpci_mib object to modify
+ * @iw_mode: new mode (%IW_MODE_*)
+ *=20
+ *  This is a helper function, hence it does not lock. Make sure
+ *  caller deals with locking *if* necessary. This function sets the=20
+ *  mode-dependent mib values and does the mapping of the Linux=20
+ *  Wireless API modes to Device firmware modes. It also checks for=20
+ *  correct valid Linux wireless modes.=20
+ */
+int
+prism54_mib_mode_helper(islpci_private *priv, u32 iw_mode)
+{
+	u32 config =3D INL_CONFIG_MANUALRUN;
+	u32 mode, bsstype;
+
+	/* For now, just catch early the Repeater and Secondary modes here */
+	if (iw_mode =3D=3D IW_MODE_REPEAT || iw_mode =3D=3D IW_MODE_SECOND) {
+		printk(KERN_DEBUG
+		       "%s(): Sorry, Repeater mode and Secondary mode "
+		       "are not yet supported by this driver.\n", __FUNCTION__);
+		return -EINVAL;
+	}
+
+	priv->iw_mode =3D iw_mode;
+
+	switch (iw_mode) {
+	case IW_MODE_AUTO:
+		mode =3D INL_MODE_CLIENT;
+		bsstype =3D DOT11_BSSTYPE_ANY;
+		break;
+	case IW_MODE_ADHOC:
+		mode =3D INL_MODE_CLIENT;
+		bsstype =3D DOT11_BSSTYPE_IBSS;
+		break;
+	case IW_MODE_INFRA:
+		mode =3D INL_MODE_CLIENT;
+		bsstype =3D DOT11_BSSTYPE_INFRA;
+		break;
+	case IW_MODE_MASTER:
+		mode =3D INL_MODE_AP;
+		bsstype =3D DOT11_BSSTYPE_INFRA;
+		break;
+	case IW_MODE_MONITOR:
+		mode =3D INL_MODE_PROMISCUOUS;
+		bsstype =3D DOT11_BSSTYPE_ANY;
+		config |=3D INL_CONFIG_RXANNEX;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (init_wds)
+		config |=3D INL_CONFIG_WDS;
+	mgt_set(priv, DOT11_OID_BSSTYPE, &bsstype);
+	mgt_set(priv, OID_INL_CONFIG, &config);
+	mgt_set(priv, OID_INL_MODE, &mode);
+
+	return 0;
+}
+
+/**
+ * prism54_mib_init - fill MIB cache with defaults
+ *
+ *  this function initializes the struct given as @mib with defaults,
+ *  of which many are retrieved from the global module parameter
+ *  variables. =20
+ */
+
+void
+prism54_mib_init(islpci_private *priv)
+{
+	u32 t;
+	struct obj_buffer psm_buffer =3D {
+		.size =3D PSM_BUFFER_SIZE,
+		.addr =3D priv->device_psm_buffer
+	};
+
+	mgt_set(priv, DOT11_OID_CHANNEL, &init_channel);
+	mgt_set(priv, DOT11_OID_AUTHENABLE, &init_authen);
+	mgt_set(priv, DOT11_OID_PRIVACYINVOKED, &init_wep);
+
+	mgt_set(priv, DOT11_OID_PSMBUFFER, &psm_buffer);
+	mgt_set(priv, DOT11_OID_EXUNENCRYPTED, &init_filter);
+	mgt_set(priv, DOT11_OID_DOT1XENABLE, &init_dot1x);
+	mgt_set(priv, DOT11_OID_MLMEAUTOLEVEL, &init_mlme);
+	mgt_set(priv, OID_INL_DOT11D_CONFORMANCE, &init_conformance);
+
+	t =3D 127;
+	mgt_set(priv, OID_INL_OUTPUTPOWER, &t);
+
+	/* Important: we are setting a default wireless mode and we are=20
+	 * forcing a valid one, so prism54_mib_mode_helper should just set
+	 * mib values depending on what the wireless mode given is. No need
+	 * for it save old values */
+	if (init_mode > IW_MODE_MONITOR || init_mode < IW_MODE_AUTO) {
+		printk(KERN_DEBUG "%s(): You passed a non-valid init_mode. "
+		       "Using default mode\n", __FUNCTION__);
+		init_mode =3D CARD_DEFAULT_IW_MODE;
+	}
+	/* This sets all of the mode-dependent values */
+	prism54_mib_mode_helper(priv, init_mode);
+}
+
+/* this will be executed outside of atomic context thanks to
+ * schedule_work(), thus we can as well use sleeping semaphore
+ * locking */
+void
+prism54_update_stats(islpci_private *priv)
+{
+	char *data;
+	int j;
+	struct obj_bss bss, *bss2;
+	union oid_res_t r;
+
+	if (down_interruptible(&priv->stats_sem))
+		return;
+
+/* Noise floor.
+ * I'm not sure if the unit is dBm.
+ * Note : If we are not connected, this value seems to be irrelevant. */
+
+	mgt_get_request(priv, DOT11_OID_NOISEFLOOR, 0, NULL, &r);
+	priv->local_iwstatistics.qual.noise =3D r.u;
+
+/* Get the rssi of the link. To do this we need to retrieve a bss. */
+
+	/* First get the MAC address of the AP we are associated with. */
+	mgt_get_request(priv, DOT11_OID_BSSID, 0, NULL, &r);
+	data =3D r.ptr;
+
+	/* copy this MAC to the bss */
+	memcpy(bss.address, data, 6);
+	kfree(data);
+
+	/* now ask for the corresponding bss */
+	j =3D mgt_get_request(priv, DOT11_OID_BSSFIND, 0, (void *) &bss, &r);
+	bss2 =3D r.ptr;
+	/* report the rssi and use it to calculate
+	 *  link quality through a signal-noise
+	 *  ratio */
+	priv->local_iwstatistics.qual.level =3D bss2->rssi;
+	priv->local_iwstatistics.qual.qual =3D
+	    bss2->rssi - priv->iwstatistics.qual.noise;
+
+	kfree(bss2);
+
+	/* report that the stats are new */
+	priv->local_iwstatistics.qual.updated =3D 0x7;
+
+/* Rx : unable to decrypt the MPDU */
+	mgt_get_request(priv, DOT11_OID_PRIVRXFAILED, 0, NULL, &r);
+	priv->local_iwstatistics.discard.code =3D r.u;
+
+/* Tx : Max MAC retries num reached */
+	mgt_get_request(priv, DOT11_OID_MPDUTXFAILED, 0, NULL, &r);
+	priv->local_iwstatistics.discard.retries =3D r.u;
+
+	up(&priv->stats_sem);
+
+	return;
+}
+
+struct iw_statistics *
+prism54_get_wireless_stats(struct net_device *ndev)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+
+	/* If the stats are being updated return old data */
+	if (down_trylock(&priv->stats_sem) =3D=3D 0) {
+		memcpy(&priv->iwstatistics, &priv->local_iwstatistics,
+		       sizeof (struct iw_statistics));
+		/* They won't be marked updated for the next time */
+		priv->local_iwstatistics.qual.updated =3D 0;
+		up(&priv->stats_sem);
+	} else
+		priv->iwstatistics.qual.updated =3D 0;
+
+	/* Update our wireless stats, but do not schedule to often=20
+	 * (max 1 HZ) */
+	if ((priv->stats_timestamp =3D=3D 0) ||
+	    time_after(jiffies, priv->stats_timestamp + 1 * HZ)) {
+		schedule_work(&priv->stats_work);
+		priv->stats_timestamp =3D jiffies;
+	}
+
+	return &priv->iwstatistics;
+}
+
+static int
+prism54_commit(struct net_device *ndev, struct iw_request_info *info,
+	       char *cwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+
+	/* simply re-set the last set SSID, this should commit most stuff */
+
+	/* Commit in Monitor mode is not necessary, also setting essid
+	 * in Monitor mode does not make sense and isn't allowed for this
+	 * device's firmware */
+	if (priv->iw_mode !=3D IW_MODE_MONITOR)
+		return mgt_set_request(priv, DOT11_OID_SSID, 0, NULL);
+	return 0;
+}
+
+static int
+prism54_get_name(struct net_device *ndev, struct iw_request_info *info,
+		 char *cwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	char *capabilities;
+	union oid_res_t r;
+	int rvalue;
+
+	if (islpci_get_state(priv) < PRV_STATE_INIT) {
+		strncpy(cwrq, "NOT READY!", IFNAMSIZ);
+		return 0;
+	}
+	rvalue =3D mgt_get_request(priv, OID_INL_PHYCAPABILITIES, 0, NULL, &r);
+
+	switch (r.u) {
+	case INL_PHYCAP_5000MHZ:
+		capabilities =3D "IEEE 802.11a/b/g";
+		break;
+	case INL_PHYCAP_FAA:
+		capabilities =3D "IEEE 802.11b/g - FAA Support";
+		break;
+	case INL_PHYCAP_2400MHZ:
+	default:
+		capabilities =3D "IEEE 802.11b/g";	/* Default */
+		break;
+	}
+	strncpy(cwrq, capabilities, IFNAMSIZ);
+	return rvalue;
+}
+
+static int
+prism54_set_freq(struct net_device *ndev, struct iw_request_info *info,
+		 struct iw_freq *fwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	int rvalue;
+	u32 c;
+
+	if (fwrq->m < 1000)
+		/* we have a channel number */
+		c =3D fwrq->m;
+	else
+		c =3D (fwrq->e =3D=3D 1) ? channel_of_freq(fwrq->m / 100000) : 0;
+
+	rvalue =3D c ? mgt_set_request(priv, DOT11_OID_CHANNEL, 0, &c) : -EINVAL;
+
+	/* Call commit handler */
+	return (rvalue ? rvalue : -EINPROGRESS);
+}
+
+static int
+prism54_get_freq(struct net_device *ndev, struct iw_request_info *info,
+		 struct iw_freq *fwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	union oid_res_t r;
+	int rvalue;
+
+	rvalue =3D mgt_get_request(priv, DOT11_OID_CHANNEL, 0, NULL, &r);
+
+	fwrq->m =3D r.u;
+	fwrq->e =3D 0;
+
+	return rvalue;
+}
+
+static int
+prism54_set_mode(struct net_device *ndev, struct iw_request_info *info,
+		 __u32 * uwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	u32 mlmeautolevel =3D CARD_DEFAULT_MLME_MODE;
+
+	/* Let's see if the user passed a valid Linux Wireless mode */
+	if (*uwrq > IW_MODE_MONITOR || *uwrq < IW_MODE_AUTO) {
+		printk(KERN_DEBUG
+		       "%s: %s() You passed a non-valid init_mode.\n",
+		       priv->ndev->name, __FUNCTION__);
+		return -EINVAL;
+	}
+
+	down_write(&priv->mib_sem);
+
+	if (prism54_mib_mode_helper(priv, *uwrq)) {
+		up_write(&priv->mib_sem);
+		return -EOPNOTSUPP;
+	}
+
+	/* the ACL code needs an intermediate mlmeautolevel. The wpa stuff an
+	 * extended one.
+	 */
+	if ((*uwrq =3D=3D IW_MODE_MASTER) && (priv->acl.policy !=3D MAC_POLICY_OP=
EN))
+		mlmeautolevel =3D DOT11_MLME_INTERMEDIATE;
+	if (priv->wpa)
+		mlmeautolevel =3D DOT11_MLME_EXTENDED;
+
+	mgt_set(priv, DOT11_OID_MLMEAUTOLEVEL, &mlmeautolevel);
+
+	mgt_commit(priv);
+	priv->ndev->type =3D (priv->iw_mode =3D=3D IW_MODE_MONITOR)
+	    ? priv->monitor_type : ARPHRD_ETHER;
+	up_write(&priv->mib_sem);
+
+	return 0;
+}
+
+/* Use mib cache */
+static int
+prism54_get_mode(struct net_device *ndev, struct iw_request_info *info,
+		 __u32 * uwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+
+	BUG_ON((priv->iw_mode < IW_MODE_AUTO) || (priv->iw_mode >
+						  IW_MODE_MONITOR));
+	*uwrq =3D priv->iw_mode;
+
+	return 0;
+}
+
+/* we use DOT11_OID_EDTHRESHOLD. From what I guess the card will not try to
+ * emit data if (sensitivity > rssi - noise) (in dBm).
+ * prism54_set_sens does not seem to work.
+ */
+
+static int
+prism54_set_sens(struct net_device *ndev, struct iw_request_info *info,
+		 struct iw_param *vwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	u32 sens;
+
+	/* by default  the card sets this to 20. */
+	sens =3D vwrq->disabled ? 20 : vwrq->value;
+
+	return mgt_set_request(priv, DOT11_OID_EDTHRESHOLD, 0, &sens);
+}
+
+static int
+prism54_get_sens(struct net_device *ndev, struct iw_request_info *info,
+		 struct iw_param *vwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	union oid_res_t r;
+	int rvalue;
+
+	rvalue =3D mgt_get_request(priv, DOT11_OID_EDTHRESHOLD, 0, NULL, &r);
+
+	vwrq->value =3D r.u;
+	vwrq->disabled =3D (vwrq->value =3D=3D 0);
+	vwrq->fixed =3D 1;
+
+	return rvalue;
+}
+
+static int
+prism54_get_range(struct net_device *ndev, struct iw_request_info *info,
+		  struct iw_point *dwrq, char *extra)
+{
+	struct iw_range *range =3D (struct iw_range *) extra;
+	islpci_private *priv =3D netdev_priv(ndev);
+	char *data;
+	int i, m, rvalue;
+	struct obj_frequencies *freq;
+	union oid_res_t r;
+
+	memset(range, 0, sizeof (struct iw_range));
+	dwrq->length =3D sizeof (struct iw_range);
+
+	/* set the wireless extension version number */
+	range->we_version_source =3D SUPPORTED_WIRELESS_EXT;
+	range->we_version_compiled =3D WIRELESS_EXT;
+
+	/* Now the encoding capabilities */
+	range->num_encoding_sizes =3D 3;
+	/* 64(40) bits WEP */
+	range->encoding_size[0] =3D 5;
+	/* 128(104) bits WEP */
+	range->encoding_size[1] =3D 13;
+	/* 256 bits for WPA-PSK */
+	range->encoding_size[2] =3D 32;
+	/* 4 keys are allowed */
+	range->max_encoding_tokens =3D 4;
+
+	/* we don't know the quality range... */
+	range->max_qual.level =3D 0;
+	range->max_qual.noise =3D 0;
+	range->max_qual.qual =3D 0;
+	/* these value describe an average quality. Needs more tweaking... */
+	range->avg_qual.level =3D -80;	/* -80 dBm */
+	range->avg_qual.noise =3D 0;	/* don't know what to put here */
+	range->avg_qual.qual =3D 0;
+
+	range->sensitivity =3D 200;
+
+	/* retry limit capabilities */
+	range->retry_capa =3D IW_RETRY_LIMIT | IW_RETRY_LIFETIME;
+	range->retry_flags =3D IW_RETRY_LIMIT;
+	range->r_time_flags =3D IW_RETRY_LIFETIME;
+
+	/* I don't know the range. Put stupid things here */
+	range->min_retry =3D 1;
+	range->max_retry =3D 65535;
+	range->min_r_time =3D 1024;
+	range->max_r_time =3D 65535 * 1024;
+
+	/* txpower is supported in dBm's */
+	range->txpower_capa =3D IW_TXPOW_DBM;
+
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return 0;
+
+	/* Request the device for the supported frequencies
+	 * not really relevant since some devices will report the 5 GHz band
+	 * frequencies even if they don't support them.
+	 */
+	rvalue =3D
+	    mgt_get_request(priv, DOT11_OID_SUPPORTEDFREQUENCIES, 0, NULL, &r);
+	freq =3D r.ptr;
+
+	range->num_channels =3D freq->nr;
+	range->num_frequency =3D freq->nr;
+
+	m =3D min(IW_MAX_FREQUENCIES, (int) freq->nr);
+	for (i =3D 0; i < m; i++) {
+		range->freq[i].m =3D freq->mhz[i];
+		range->freq[i].e =3D 6;
+		range->freq[i].i =3D channel_of_freq(freq->mhz[i]);
+	}
+	kfree(freq);
+
+	rvalue |=3D mgt_get_request(priv, DOT11_OID_SUPPORTEDRATES, 0, NULL, &r);
+	data =3D r.ptr;
+
+	/* We got an array of char. It is NULL terminated. */
+	i =3D 0;
+	while ((i < IW_MAX_BITRATES) && (*data !=3D 0)) {
+		/*       the result must be in bps. The card gives us 500Kbps */
+		range->bitrate[i] =3D (__s32) (*data >> 1);
+		range->bitrate[i] *=3D 1000000;
+		i++;
+		data++;
+	}
+	range->num_bitrates =3D i;
+	kfree(r.ptr);
+
+	return rvalue;
+}
+
+/* Set AP address*/
+
+static int
+prism54_set_wap(struct net_device *ndev, struct iw_request_info *info,
+		struct sockaddr *awrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	char bssid[6];
+	int rvalue;
+
+	if (awrq->sa_family !=3D ARPHRD_ETHER)
+		return -EINVAL;
+
+	/* prepare the structure for the set object */
+	memcpy(&bssid[0], awrq->sa_data, 6);
+
+	/* set the bssid -- does this make sense when in AP mode? */
+	rvalue =3D mgt_set_request(priv, DOT11_OID_BSSID, 0, &bssid);
+
+	return (rvalue ? rvalue : -EINPROGRESS);	/* Call commit handler */
+}
+
+/* get AP address*/
+
+static int
+prism54_get_wap(struct net_device *ndev, struct iw_request_info *info,
+		struct sockaddr *awrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	union oid_res_t r;
+	int rvalue;
+
+	rvalue =3D mgt_get_request(priv, DOT11_OID_BSSID, 0, NULL, &r);
+	memcpy(awrq->sa_data, r.ptr, 6);
+	awrq->sa_family =3D ARPHRD_ETHER;
+	kfree(r.ptr);
+
+	return rvalue;
+}
+
+static int
+prism54_set_scan(struct net_device *dev, struct iw_request_info *info,
+		 struct iw_param *vwrq, char *extra)
+{
+	/* hehe the device does this automagicaly */
+	return 0;
+}
+
+/* a little helper that will translate our data into a card independent
+ * format that the Wireless Tools will understand. This was inspired by
+ * the "Aironet driver for 4500 and 4800 series cards" (GPL)
+ */
+
+static char *
+prism54_translate_bss(struct net_device *ndev, char *current_ev,
+		      char *end_buf, struct obj_bss *bss, char noise)
+{
+	struct iw_event iwe;	/* Temporary buffer */
+	short cap;
+	islpci_private *priv =3D netdev_priv(ndev);
+
+	/* The first entry must be the MAC address */
+	memcpy(iwe.u.ap_addr.sa_data, bss->address, 6);
+	iwe.u.ap_addr.sa_family =3D ARPHRD_ETHER;
+	iwe.cmd =3D SIOCGIWAP;
+	current_ev =3D
+	    iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_ADDR_LEN);
+
+	/* The following entries will be displayed in the same order we give them=
 */
+
+	/* The ESSID. */
+	iwe.u.data.length =3D bss->ssid.length;
+	iwe.u.data.flags =3D 1;
+	iwe.cmd =3D SIOCGIWESSID;
+	current_ev =3D iwe_stream_add_point(current_ev, end_buf,
+					  &iwe, bss->ssid.octets);
+
+	/* Capabilities */
+#define CAP_ESS 0x01
+#define CAP_IBSS 0x02
+#define CAP_CRYPT 0x10
+
+	/* Mode */
+	cap =3D bss->capinfo;
+	iwe.u.mode =3D 0;
+	if (cap & CAP_ESS)
+		iwe.u.mode =3D IW_MODE_MASTER;
+	else if (cap & CAP_IBSS)
+		iwe.u.mode =3D IW_MODE_ADHOC;
+	iwe.cmd =3D SIOCGIWMODE;
+	if (iwe.u.mode)
+		current_ev =3D
+		    iwe_stream_add_event(current_ev, end_buf, &iwe,
+					 IW_EV_UINT_LEN);
+
+	/* Encryption capability */
+	if (cap & CAP_CRYPT)
+		iwe.u.data.flags =3D IW_ENCODE_ENABLED | IW_ENCODE_NOKEY;
+	else
+		iwe.u.data.flags =3D IW_ENCODE_DISABLED;
+	iwe.u.data.length =3D 0;
+	iwe.cmd =3D SIOCGIWENCODE;
+	current_ev =3D iwe_stream_add_point(current_ev, end_buf, &iwe, NULL);
+
+	/* Add frequency. (short) bss->channel is the frequency in MHz */
+	iwe.u.freq.m =3D channel_of_freq(bss->channel);
+	iwe.u.freq.e =3D 0;
+	iwe.cmd =3D SIOCGIWFREQ;
+	current_ev =3D
+	    iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_FREQ_LEN);
+
+	/* Add quality statistics */
+	iwe.u.qual.level =3D bss->rssi;
+	iwe.u.qual.noise =3D noise;
+	/* do a simple SNR for quality */
+	iwe.u.qual.qual =3D bss->rssi - noise;
+	iwe.cmd =3D IWEVQUAL;
+	current_ev =3D
+	    iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_QUAL_LEN);
+
+	if (priv->wpa) {
+		u8 wpa_ie[MAX_WPA_IE_LEN];
+		char *buf, *p;
+		size_t wpa_ie_len;
+		int i;
+
+		wpa_ie_len =3D prism54_wpa_ie_get(priv, bss->address, wpa_ie);
+		if (wpa_ie_len > 0 &&
+		    (buf =3D kmalloc(wpa_ie_len * 2 + 10, GFP_ATOMIC))) {
+			p =3D buf;
+			p +=3D sprintf(p, "wpa_ie=3D");
+			for (i =3D 0; i < wpa_ie_len; i++) {
+				p +=3D sprintf(p, "%02x", wpa_ie[i]);
+			}
+			memset(&iwe, 0, sizeof (iwe));
+			iwe.cmd =3D IWEVCUSTOM;
+			iwe.u.data.length =3D strlen(buf);
+			current_ev =3D iwe_stream_add_point(current_ev, end_buf,
+							  &iwe, buf);
+			kfree(buf);
+		}
+	}
+	return current_ev;
+}
+
+int
+prism54_get_scan(struct net_device *ndev, struct iw_request_info *info,
+		 struct iw_point *dwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	int i, rvalue;
+	struct obj_bsslist *bsslist;
+	u32 noise =3D 0;
+	char *current_ev =3D extra;
+	union oid_res_t r;
+
+	if (islpci_get_state(priv) < PRV_STATE_INIT) {
+		/* device is not ready, fail gently */
+		dwrq->length =3D 0;
+		return 0;
+	}
+
+	/* first get the noise value. We will use it to report the link quality */
+	rvalue =3D mgt_get_request(priv, DOT11_OID_NOISEFLOOR, 0, NULL, &r);
+	noise =3D r.u;
+
+	/* Ask the device for a list of known bss. We can report at most
+	 * IW_MAX_AP=3D64 to the range struct. But the device won't repport anyth=
ing
+	 * if you change the value of IWMAX_BSS=3D24.
+	 */
+	rvalue |=3D mgt_get_request(priv, DOT11_OID_BSSLIST, 0, NULL, &r);
+	bsslist =3D r.ptr;
+
+	/* ok now, scan the list and translate its info */
+	for (i =3D 0; i < min(IW_MAX_AP, (int) bsslist->nr); i++)
+		current_ev =3D prism54_translate_bss(ndev, current_ev,
+						   extra + IW_SCAN_MAX_DATA,
+						   &(bsslist->bsslist[i]),
+						   noise);
+	kfree(bsslist);
+	dwrq->length =3D (current_ev - extra);
+	dwrq->flags =3D 0;	/* todo */
+
+	return rvalue;
+}
+
+static int
+prism54_set_essid(struct net_device *ndev, struct iw_request_info *info,
+		  struct iw_point *dwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	struct obj_ssid essid;
+
+	memset(essid.octets, 0, 33);
+
+	/* Check if we were asked for `any' */
+	if (dwrq->flags && dwrq->length) {
+		if (dwrq->length > min(33, IW_ESSID_MAX_SIZE + 1))
+			return -E2BIG;
+		essid.length =3D dwrq->length - 1;
+		memcpy(essid.octets, extra, dwrq->length);
+	} else
+		essid.length =3D 0;
+
+	if (priv->iw_mode !=3D IW_MODE_MONITOR)
+		return mgt_set_request(priv, DOT11_OID_SSID, 0, &essid);
+
+	/* If in monitor mode, just save to mib */
+	mgt_set(priv, DOT11_OID_SSID, &essid);
+	return 0;
+
+}
+
+static int
+prism54_get_essid(struct net_device *ndev, struct iw_request_info *info,
+		  struct iw_point *dwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	struct obj_ssid *essid;
+	union oid_res_t r;
+	int rvalue;
+
+	rvalue =3D mgt_get_request(priv, DOT11_OID_SSID, 0, NULL, &r);
+	essid =3D r.ptr;
+
+	if (essid->length) {
+		dwrq->flags =3D 1;	/* set ESSID to ON for Wireless Extensions */
+		/* if it is to big, trunk it */
+		dwrq->length =3D min(IW_ESSID_MAX_SIZE, essid->length + 1);
+	} else {
+		dwrq->flags =3D 0;
+		dwrq->length =3D 0;
+	}
+	essid->octets[essid->length] =3D '\0';
+	memcpy(extra, essid->octets, dwrq->length);
+	kfree(essid);
+
+	return rvalue;
+}
+
+/* Provides no functionality, just completes the ioctl. In essence this is=
 a=20
+ * just a cosmetic ioctl.
+ */
+static int
+prism54_set_nick(struct net_device *ndev, struct iw_request_info *info,
+		 struct iw_point *dwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+
+	if (dwrq->length > IW_ESSID_MAX_SIZE)
+		return -E2BIG;
+
+	down_write(&priv->mib_sem);
+	memset(priv->nickname, 0, sizeof (priv->nickname));
+	memcpy(priv->nickname, extra, dwrq->length);
+	up_write(&priv->mib_sem);
+
+	return 0;
+}
+
+static int
+prism54_get_nick(struct net_device *ndev, struct iw_request_info *info,
+		 struct iw_point *dwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+
+	dwrq->length =3D 0;
+
+	down_read(&priv->mib_sem);
+	dwrq->length =3D strlen(priv->nickname) + 1;
+	memcpy(extra, priv->nickname, dwrq->length);
+	up_read(&priv->mib_sem);
+
+	return 0;
+}
+
+/* Set the allowed Bitrates */
+
+static int
+prism54_set_rate(struct net_device *ndev,
+		 struct iw_request_info *info,
+		 struct iw_param *vwrq, char *extra)
+{
+
+	islpci_private *priv =3D netdev_priv(ndev);
+	u32 rate, profile;
+	char *data;
+	int ret, i;
+	union oid_res_t r;
+
+	if (vwrq->value =3D=3D -1) {
+		/* auto mode. No limit. */
+		profile =3D 1;
+		return mgt_set_request(priv, DOT11_OID_PROFILES, 0, &profile);
+	}
+
+	if ((ret =3D
+	     mgt_get_request(priv, DOT11_OID_SUPPORTEDRATES, 0, NULL, &r)))
+		return ret;
+
+	rate =3D (u32) (vwrq->value / 500000);
+	data =3D r.ptr;
+	i =3D 0;
+
+	while (data[i]) {
+		if (rate && (data[i] =3D=3D rate)) {
+			break;
+		}
+		if (vwrq->value =3D=3D i) {
+			break;
+		}
+		data[i] |=3D 0x80;
+		i++;
+	}
+
+	if (!data[i]) {
+		return -EINVAL;
+	}
+
+	data[i] |=3D 0x80;
+	data[i + 1] =3D 0;
+
+	/* Now, check if we want a fixed or auto value */
+	if (vwrq->fixed) {
+		data[0] =3D data[i];
+		data[1] =3D 0;
+	}
+
+/*
+	i =3D 0;
+	printk("prism54 rate: ");
+	while(data[i]) {
+		printk("%u ", data[i]);
+		i++;
+	}
+	printk("0\n");
+*/
+	profile =3D -1;
+	ret =3D mgt_set_request(priv, DOT11_OID_PROFILES, 0, &profile);
+	ret |=3D mgt_set_request(priv, DOT11_OID_EXTENDEDRATES, 0, data);
+	ret |=3D mgt_set_request(priv, DOT11_OID_RATES, 0, data);
+
+	kfree(r.ptr);
+
+	return ret;
+}
+
+/* Get the current bit rate */
+static int
+prism54_get_rate(struct net_device *ndev,
+		 struct iw_request_info *info,
+		 struct iw_param *vwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	int rvalue;
+	char *data;
+	union oid_res_t r;
+
+	/* Get the current bit rate */
+	if ((rvalue =3D mgt_get_request(priv, GEN_OID_LINKSTATE, 0, NULL, &r)))
+		return rvalue;
+	vwrq->value =3D r.u * 500000;
+
+	/* request the device for the enabled rates */
+	if ((rvalue =3D mgt_get_request(priv, DOT11_OID_RATES, 0, NULL, &r)))
+		return rvalue;
+	data =3D r.ptr;
+	vwrq->fixed =3D (data[0] !=3D 0) && (data[1] =3D=3D 0);
+	kfree(r.ptr);
+
+	return 0;
+}
+
+static int
+prism54_set_rts(struct net_device *ndev, struct iw_request_info *info,
+		struct iw_param *vwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+
+	return mgt_set_request(priv, DOT11_OID_RTSTHRESH, 0, &vwrq->value);
+}
+
+static int
+prism54_get_rts(struct net_device *ndev, struct iw_request_info *info,
+		struct iw_param *vwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	union oid_res_t r;
+	int rvalue;
+
+	/* get the rts threshold */
+	rvalue =3D mgt_get_request(priv, DOT11_OID_RTSTHRESH, 0, NULL, &r);
+	vwrq->value =3D r.u;
+
+	return rvalue;
+}
+
+static int
+prism54_set_frag(struct net_device *ndev, struct iw_request_info *info,
+		 struct iw_param *vwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+
+	return mgt_set_request(priv, DOT11_OID_FRAGTHRESH, 0, &vwrq->value);
+}
+
+static int
+prism54_get_frag(struct net_device *ndev, struct iw_request_info *info,
+		 struct iw_param *vwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	union oid_res_t r;
+	int rvalue;
+
+	rvalue =3D mgt_get_request(priv, DOT11_OID_FRAGTHRESH, 0, NULL, &r);
+	vwrq->value =3D r.u;
+
+	return rvalue;
+}
+
+/* Here we have (min,max) =3D max retries for (small frames, big frames). =
Where
+ * big frame <=3D>  bigger than the rts threshold
+ * small frame <=3D>  smaller than the rts threshold
+ * This is not really the behavior expected by the wireless tool but it se=
ems
+ * to be a common behavior in other drivers.
+ */
+
+static int
+prism54_set_retry(struct net_device *ndev, struct iw_request_info *info,
+		  struct iw_param *vwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	u32 slimit =3D 0, llimit =3D 0;	/* short and long limit */
+	u32 lifetime =3D 0;
+	int rvalue =3D 0;
+
+	if (vwrq->disabled)
+		/* we cannot disable this feature */
+		return -EINVAL;
+
+	if (vwrq->flags & IW_RETRY_LIMIT) {
+		if (vwrq->flags & IW_RETRY_MIN)
+			slimit =3D vwrq->value;
+		else if (vwrq->flags & IW_RETRY_MAX)
+			llimit =3D vwrq->value;
+		else {
+			/* we are asked to set both */
+			slimit =3D vwrq->value;
+			llimit =3D vwrq->value;
+		}
+	}
+	if (vwrq->flags & IW_RETRY_LIFETIME)
+		/* Wireless tools use us unit while the device uses 1024 us unit */
+		lifetime =3D vwrq->value / 1024;
+
+	/* now set what is requested */
+	if (slimit)
+		rvalue =3D
+		    mgt_set_request(priv, DOT11_OID_SHORTRETRIES, 0, &slimit);
+	if (llimit)
+		rvalue |=3D
+		    mgt_set_request(priv, DOT11_OID_LONGRETRIES, 0, &llimit);
+	if (lifetime)
+		rvalue |=3D
+		    mgt_set_request(priv, DOT11_OID_MAXTXLIFETIME, 0,
+				    &lifetime);
+	return rvalue;
+}
+
+static int
+prism54_get_retry(struct net_device *ndev, struct iw_request_info *info,
+		  struct iw_param *vwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	union oid_res_t r;
+	int rvalue =3D 0;
+	vwrq->disabled =3D 0;	/* It cannot be disabled */
+
+	if ((vwrq->flags & IW_RETRY_TYPE) =3D=3D IW_RETRY_LIFETIME) {
+		/* we are asked for the life time */
+		rvalue =3D
+		    mgt_get_request(priv, DOT11_OID_MAXTXLIFETIME, 0, NULL, &r);
+		vwrq->value =3D r.u * 1024;
+		vwrq->flags =3D IW_RETRY_LIFETIME;
+	} else if ((vwrq->flags & IW_RETRY_MAX)) {
+		/* we are asked for the long retry limit */
+		rvalue |=3D
+		    mgt_get_request(priv, DOT11_OID_LONGRETRIES, 0, NULL, &r);
+		vwrq->value =3D r.u;
+		vwrq->flags =3D IW_RETRY_LIMIT | IW_RETRY_MAX;
+	} else {
+		/* default. get the  short retry limit */
+		rvalue |=3D
+		    mgt_get_request(priv, DOT11_OID_SHORTRETRIES, 0, NULL, &r);
+		vwrq->value =3D r.u;
+		vwrq->flags =3D IW_RETRY_LIMIT | IW_RETRY_MIN;
+	}
+
+	return rvalue;
+}
+
+static int
+prism54_set_encode(struct net_device *ndev, struct iw_request_info *info,
+		   struct iw_point *dwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	int rvalue =3D 0, force =3D 0;
+	int authen =3D DOT11_AUTH_OS, invoke =3D 0, exunencrypt =3D 0;
+	union oid_res_t r;
+
+	/* with the new API, it's impossible to get a NULL pointer.
+	 * New version of iwconfig set the IW_ENCODE_NOKEY flag
+	 * when no key is given, but older versions don't. */
+
+	if (dwrq->length > 0) {
+		/* we have a key to set */
+		int index =3D (dwrq->flags & IW_ENCODE_INDEX) - 1;
+		int current_index;
+		struct obj_key key =3D { DOT11_PRIV_WEP, 0, "" };
+
+		/* get the current key index */
+		rvalue =3D mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
+		current_index =3D r.u;
+		/* Verify that the key is not marked as invalid */
+		if (!(dwrq->flags & IW_ENCODE_NOKEY)) {
+			key.length =3D dwrq->length > sizeof (key.key) ?
+			    sizeof (key.key) : dwrq->length;
+			memcpy(key.key, extra, key.length);
+			if (key.length =3D=3D 32)
+				/* we want WPA-PSK */
+				key.type =3D DOT11_PRIV_TKIP;
+			if ((index < 0) || (index > 3))
+				/* no index provided use the current one */
+				index =3D current_index;
+
+			/* now send the key to the card  */
+			rvalue |=3D
+			    mgt_set_request(priv, DOT11_OID_DEFKEYX, index,
+					    &key);
+		}
+		/*
+		 * If a valid key is set, encryption should be enabled=20
+		 * (user may turn it off later).
+		 * This is also how "iwconfig ethX key on" works
+		 */
+		if ((index =3D=3D current_index) && (key.length > 0))
+			force =3D 1;
+	} else {
+		int index =3D (dwrq->flags & IW_ENCODE_INDEX) - 1;
+		if ((index >=3D 0) && (index <=3D 3)) {
+			/* we want to set the key index */
+			rvalue |=3D
+			    mgt_set_request(priv, DOT11_OID_DEFKEYID, 0,
+					    &index);
+		} else {
+			if (!dwrq->flags & IW_ENCODE_MODE) {
+				/* we cannot do anything. Complain. */
+				return -EINVAL;
+			}
+		}
+	}
+	/* now read the flags */
+	if (dwrq->flags & IW_ENCODE_DISABLED) {
+		/* Encoding disabled,=20
+		 * authen =3D DOT11_AUTH_OS;
+		 * invoke =3D 0;
+		 * exunencrypt =3D 0; */
+	}
+	if (dwrq->flags & IW_ENCODE_OPEN)
+		/* Encode but accept non-encoded packets. No auth */
+		invoke =3D 1;
+	if ((dwrq->flags & IW_ENCODE_RESTRICTED) || force) {
+		/* Refuse non-encoded packets. Auth */
+		authen =3D DOT11_AUTH_BOTH;
+		invoke =3D 1;
+		exunencrypt =3D 1;
+	}
+	/* do the change if requested  */
+	if ((dwrq->flags & IW_ENCODE_MODE) || force) {
+		rvalue |=3D
+		    mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0, &authen);
+		rvalue |=3D
+		    mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0, &invoke);
+		rvalue |=3D
+		    mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0,
+				    &exunencrypt);
+	}
+	return rvalue;
+}
+
+static int
+prism54_get_encode(struct net_device *ndev, struct iw_request_info *info,
+		   struct iw_point *dwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	struct obj_key *key;
+	u32 devindex, index =3D (dwrq->flags & IW_ENCODE_INDEX) - 1;
+	u32 authen =3D 0, invoke =3D 0, exunencrypt =3D 0;
+	int rvalue;
+	union oid_res_t r;
+
+	/* first get the flags */
+	rvalue =3D mgt_get_request(priv, DOT11_OID_AUTHENABLE, 0, NULL, &r);
+	authen =3D r.u;
+	rvalue |=3D mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 0, NULL, &r);
+	invoke =3D r.u;
+	rvalue |=3D mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 0, NULL, &r);
+	exunencrypt =3D r.u;
+
+	if (invoke && (authen =3D=3D DOT11_AUTH_BOTH) && exunencrypt)
+		dwrq->flags =3D IW_ENCODE_RESTRICTED;
+	else if ((authen =3D=3D DOT11_AUTH_OS) && !exunencrypt) {
+		if (invoke)
+			dwrq->flags =3D IW_ENCODE_OPEN;
+		else
+			dwrq->flags =3D IW_ENCODE_DISABLED;
+	} else
+		/* The card should not work in this state */
+		dwrq->flags =3D 0;
+
+	/* get the current device key index */
+	rvalue |=3D mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
+	devindex =3D r.u;
+	/* Now get the key, return it */
+	if ((index < 0) || (index > 3))
+		/* no index provided, use the current one */
+		index =3D devindex;
+	rvalue |=3D mgt_get_request(priv, DOT11_OID_DEFKEYX, index, NULL, &r);
+	key =3D r.ptr;
+	dwrq->length =3D key->length;
+	memcpy(extra, key->key, dwrq->length);
+	kfree(key);
+	/* return the used key index */
+	dwrq->flags |=3D devindex + 1;
+
+	return rvalue;
+}
+
+static int
+prism54_get_txpower(struct net_device *ndev, struct iw_request_info *info,
+		    struct iw_param *vwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	union oid_res_t r;
+	int rvalue;
+
+	rvalue =3D mgt_get_request(priv, OID_INL_OUTPUTPOWER, 0, NULL, &r);
+	/* intersil firmware operates in 0.25 dBm (1/4 dBm) */
+	vwrq->value =3D (s32) r.u / 4;
+	vwrq->fixed =3D 1;
+	/* radio is not turned of
+	 * btw: how is possible to turn off only the radio=20
+	 */
+	vwrq->disabled =3D 0;
+
+	return rvalue;
+}
+
+static int
+prism54_set_txpower(struct net_device *ndev, struct iw_request_info *info,
+		    struct iw_param *vwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	s32 u =3D vwrq->value;
+
+	/* intersil firmware operates in 0.25 dBm (1/4) */
+	u *=3D 4;
+	if (vwrq->disabled) {
+		/* don't know how to disable radio */
+		printk(KERN_DEBUG
+		       "%s: %s() disabling radio is not yet supported.\n",
+		       priv->ndev->name, __FUNCTION__);
+		return -ENOTSUPP;
+	} else if (vwrq->fixed)
+		/* currently only fixed value is supported */
+		return mgt_set_request(priv, OID_INL_OUTPUTPOWER, 0, &u);
+	else {
+		printk(KERN_DEBUG
+		       "%s: %s() auto power will be implemented later.\n",
+		       priv->ndev->name, __FUNCTION__);
+		return -ENOTSUPP;
+	}
+}
+
+static int
+prism54_reset(struct net_device *ndev, struct iw_request_info *info,
+	      __u32 * uwrq, char *extra)
+{
+	islpci_reset(netdev_priv(ndev), 0);
+
+	return 0;
+}
+
+static int
+prism54_get_oid(struct net_device *ndev, struct iw_request_info *info,
+		struct iw_point *dwrq, char *extra)
+{
+	union oid_res_t r;
+	int rvalue;
+	enum oid_num_t n =3D dwrq->flags;
+
+	rvalue =3D mgt_get_request((islpci_private *) ndev->priv, n, 0, NULL, &r);
+	dwrq->length =3D mgt_response_to_str(n, &r, extra);
+	if ((isl_oid[n].flags & OID_FLAG_TYPE) !=3D OID_TYPE_U32)
+		kfree(r.ptr);
+	return rvalue;
+}
+
+static int
+prism54_set_u32(struct net_device *ndev, struct iw_request_info *info,
+		__u32 * uwrq, char *extra)
+{
+	u32 oid =3D uwrq[0], u =3D uwrq[1];
+
+	return mgt_set_request((islpci_private *) ndev->priv, oid, 0, &u);
+}
+
+static int
+prism54_set_raw(struct net_device *ndev, struct iw_request_info *info,
+		struct iw_point *dwrq, char *extra)
+{
+	u32 oid =3D dwrq->flags;
+
+	return mgt_set_request((islpci_private *) ndev->priv, oid, 0, extra);
+}
+
+void
+prism54_acl_init(struct islpci_acl *acl)
+{
+	sema_init(&acl->sem, 1);
+	INIT_LIST_HEAD(&acl->mac_list);
+	acl->size =3D 0;
+	acl->policy =3D MAC_POLICY_OPEN;
+}
+
+static void
+prism54_clear_mac(struct islpci_acl *acl)
+{
+	struct list_head *ptr, *next;
+	struct mac_entry *entry;
+
+	if (down_interruptible(&acl->sem))
+		return;
+
+	if (acl->size =3D=3D 0) {
+		up(&acl->sem);
+		return;
+	}
+
+	for (ptr =3D acl->mac_list.next, next =3D ptr->next;
+	     ptr !=3D &acl->mac_list; ptr =3D next, next =3D ptr->next) {
+		entry =3D list_entry(ptr, struct mac_entry, _list);
+		list_del(ptr);
+		kfree(entry);
+	}
+	acl->size =3D 0;
+	up(&acl->sem);
+}
+
+void
+prism54_acl_clean(struct islpci_acl *acl)
+{
+	prism54_clear_mac(acl);
+}
+
+static int
+prism54_add_mac(struct net_device *ndev, struct iw_request_info *info,
+		struct sockaddr *awrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	struct islpci_acl *acl =3D &priv->acl;
+	struct mac_entry *entry;
+	struct sockaddr *addr =3D (struct sockaddr *) extra;
+
+	if (addr->sa_family !=3D ARPHRD_ETHER)
+		return -EOPNOTSUPP;
+
+	entry =3D kmalloc(sizeof (struct mac_entry), GFP_KERNEL);
+	if (entry =3D=3D NULL)
+		return -ENOMEM;
+
+	memcpy(entry->addr, addr->sa_data, ETH_ALEN);
+
+	if (down_interruptible(&acl->sem)) {
+		kfree(entry);
+		return -ERESTARTSYS;
+	}
+	list_add_tail(&entry->_list, &acl->mac_list);
+	acl->size++;
+	up(&acl->sem);
+
+	return 0;
+}
+
+static int
+prism54_del_mac(struct net_device *ndev, struct iw_request_info *info,
+		struct sockaddr *awrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	struct islpci_acl *acl =3D &priv->acl;
+	struct mac_entry *entry;
+	struct list_head *ptr;
+	struct sockaddr *addr =3D (struct sockaddr *) extra;
+
+	if (addr->sa_family !=3D ARPHRD_ETHER)
+		return -EOPNOTSUPP;
+
+	if (down_interruptible(&acl->sem))
+		return -ERESTARTSYS;
+	for (ptr =3D acl->mac_list.next; ptr !=3D &acl->mac_list; ptr =3D ptr->ne=
xt) {
+		entry =3D list_entry(ptr, struct mac_entry, _list);
+
+		if (memcmp(entry->addr, addr->sa_data, ETH_ALEN) =3D=3D 0) {
+			list_del(ptr);
+			acl->size--;
+			kfree(entry);
+			up(&acl->sem);
+			return 0;
+		}
+	}
+	up(&acl->sem);
+	return -EINVAL;
+}
+
+static int
+prism54_get_mac(struct net_device *ndev, struct iw_request_info *info,
+		struct iw_point *dwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	struct islpci_acl *acl =3D &priv->acl;
+	struct mac_entry *entry;
+	struct list_head *ptr;
+	struct sockaddr *dst =3D (struct sockaddr *) extra;
+
+	dwrq->length =3D 0;
+
+	if (down_interruptible(&acl->sem))
+		return -ERESTARTSYS;
+
+	for (ptr =3D acl->mac_list.next; ptr !=3D &acl->mac_list; ptr =3D ptr->ne=
xt) {
+		entry =3D list_entry(ptr, struct mac_entry, _list);
+
+		memcpy(dst->sa_data, entry->addr, ETH_ALEN);
+		dst->sa_family =3D ARPHRD_ETHER;
+		dwrq->length++;
+		dst++;
+	}
+	up(&acl->sem);
+	return 0;
+}
+
+/* Setting policy also clears the MAC acl, even if we don't change the def=
aut
+ * policy
+ */
+
+static int
+prism54_set_policy(struct net_device *ndev, struct iw_request_info *info,
+		   __u32 * uwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	struct islpci_acl *acl =3D &priv->acl;
+	u32 mlmeautolevel;
+
+	prism54_clear_mac(acl);
+
+	if ((*uwrq < MAC_POLICY_OPEN) || (*uwrq > MAC_POLICY_REJECT))
+		return -EINVAL;
+
+	down_write(&priv->mib_sem);
+
+	acl->policy =3D *uwrq;
+
+	/* the ACL code needs an intermediate mlmeautolevel */
+	if ((priv->iw_mode =3D=3D IW_MODE_MASTER) &&
+	    (acl->policy !=3D MAC_POLICY_OPEN))
+		mlmeautolevel =3D DOT11_MLME_INTERMEDIATE;
+	else
+		mlmeautolevel =3D CARD_DEFAULT_MLME_MODE;
+	if (priv->wpa)
+		mlmeautolevel =3D DOT11_MLME_EXTENDED;
+	mgt_set(priv, DOT11_OID_MLMEAUTOLEVEL, &mlmeautolevel);
+	/* restart the card with our new policy */
+	mgt_commit(priv);
+	up_write(&priv->mib_sem);
+
+	return 0;
+}
+
+static int
+prism54_get_policy(struct net_device *ndev, struct iw_request_info *info,
+		   __u32 * uwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	struct islpci_acl *acl =3D &priv->acl;
+
+	*uwrq =3D acl->policy;
+
+	return 0;
+}
+
+/* Return 1 only if client should be accepted. */
+
+static int
+prism54_mac_accept(struct islpci_acl *acl, char *mac)
+{
+	struct list_head *ptr;
+	struct mac_entry *entry;
+	int res =3D 0;
+
+	if (down_interruptible(&acl->sem))
+		return -ERESTARTSYS;
+
+	if (acl->policy =3D=3D MAC_POLICY_OPEN) {
+		up(&acl->sem);
+		return 1;
+	}
+
+	for (ptr =3D acl->mac_list.next; ptr !=3D &acl->mac_list; ptr =3D ptr->ne=
xt) {
+		entry =3D list_entry(ptr, struct mac_entry, _list);
+		if (memcmp(entry->addr, mac, ETH_ALEN) =3D=3D 0) {
+			res =3D 1;
+			break;
+		}
+	}
+	res =3D (acl->policy =3D=3D MAC_POLICY_ACCEPT) ? !res : res;
+	up(&acl->sem);
+
+	return res;
+}
+
+static int
+prism54_kick_all(struct net_device *ndev, struct iw_request_info *info,
+		 struct iw_point *dwrq, char *extra)
+{
+	struct obj_mlme *mlme;
+	int rvalue;
+
+	mlme =3D kmalloc(sizeof (struct obj_mlme), GFP_KERNEL);
+	if (mlme =3D=3D NULL)
+		return -ENOMEM;
+
+	/* Tell the card to kick every client */
+	mlme->id =3D 0;
+	rvalue =3D
+	    mgt_set_request(netdev_priv(ndev), DOT11_OID_DISASSOCIATE, 0, mlme);
+	kfree(mlme);
+
+	return rvalue;
+}
+
+static int
+prism54_kick_mac(struct net_device *ndev, struct iw_request_info *info,
+		 struct sockaddr *awrq, char *extra)
+{
+	struct obj_mlme *mlme;
+	struct sockaddr *addr =3D (struct sockaddr *) extra;
+	int rvalue;
+
+	if (addr->sa_family !=3D ARPHRD_ETHER)
+		return -EOPNOTSUPP;
+
+	mlme =3D kmalloc(sizeof (struct obj_mlme), GFP_KERNEL);
+	if (mlme =3D=3D NULL)
+		return -ENOMEM;
+
+	/* Tell the card to only kick the corresponding bastard */
+	memcpy(mlme->address, addr->sa_data, ETH_ALEN);
+	mlme->id =3D -1;
+	rvalue =3D
+	    mgt_set_request(netdev_priv(ndev), DOT11_OID_DISASSOCIATE, 0, mlme);
+
+	kfree(mlme);
+
+	return rvalue;
+}
+
+/* Translate a TRAP oid into a wireless event. Called in islpci_mgt_receiv=
e. */
+
+static void
+format_event(islpci_private *priv, char *dest, const char *str,
+	     const struct obj_mlme *mlme, u16 *length, int error)
+{
+	const u8 *a =3D mlme->address;
+	int n =3D snprintf(dest, IW_CUSTOM_MAX,
+			 "%s %s %2.2X:%2.2X:%2.2X:%2.2X:%2.2X:%2.2X %s (%2.2X)",
+			 str,
+			 ((priv->iw_mode =3D=3D IW_MODE_MASTER) ? "from" : "to"),
+			 a[0], a[1], a[2], a[3], a[4], a[5],
+			 (error ? (mlme->code ? " : REJECTED " : " : ACCEPTED ")
+			  : ""), mlme->code);
+	BUG_ON(n > IW_CUSTOM_MAX);
+	*length =3D n;
+}
+
+static void
+send_formatted_event(islpci_private *priv, const char *str,
+		     const struct obj_mlme *mlme, int error)
+{
+	union iwreq_data wrqu;
+
+	wrqu.data.pointer =3D kmalloc(IW_CUSTOM_MAX, GFP_KERNEL);
+	if (!wrqu.data.pointer)
+		return;
+	wrqu.data.length =3D 0;
+	format_event(priv, wrqu.data.pointer, str, mlme, &wrqu.data.length,
+		     error);
+	wireless_send_event(priv->ndev, IWEVCUSTOM, &wrqu, wrqu.data.pointer);
+	kfree(wrqu.data.pointer);
+}
+
+static void
+send_simple_event(islpci_private *priv, const char *str)
+{
+	union iwreq_data wrqu;
+	int n =3D strlen(str);
+
+	wrqu.data.pointer =3D kmalloc(IW_CUSTOM_MAX, GFP_KERNEL);
+	if (!wrqu.data.pointer)
+		return;
+	BUG_ON(n > IW_CUSTOM_MAX);
+	wrqu.data.length =3D n;
+	strcpy(wrqu.data.pointer, str);
+	wireless_send_event(priv->ndev, IWEVCUSTOM, &wrqu, wrqu.data.pointer);
+	kfree(wrqu.data.pointer);
+}
+
+static void
+link_changed(struct net_device *ndev, u32 bitrate)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+
+	if (bitrate) {
+		if (priv->iw_mode =3D=3D IW_MODE_INFRA) {
+			union iwreq_data uwrq;
+			prism54_get_wap(ndev, NULL, (struct sockaddr *) &uwrq,
+					NULL);
+			wireless_send_event(ndev, SIOCGIWAP, &uwrq, NULL);
+		} else
+			send_simple_event(netdev_priv(ndev),
+					  "Link established");
+	} else
+		send_simple_event(netdev_priv(ndev), "Link lost");
+}
+
+/* Beacon/ProbeResp payload header */
+struct ieee80211_beacon_phdr {
+	u8 timestamp[8];
+	u16 beacon_int;
+	u16 capab_info;
+} __attribute__ ((packed));
+
+#define WLAN_EID_GENERIC 0xdd
+static u8 wpa_oid[4] =3D { 0x00, 0x50, 0xf2, 1 };
+
+#define MAC2STR(a) (a)[0], (a)[1], (a)[2], (a)[3], (a)[4], (a)[5]
+#define MACSTR "%02x:%02x:%02x:%02x:%02x:%02x"
+
+void
+prism54_wpa_ie_add(islpci_private *priv, u8 *bssid,
+		   u8 *wpa_ie, size_t wpa_ie_len)
+{
+	struct list_head *ptr;
+	struct islpci_bss_wpa_ie *bss =3D NULL;
+
+	if (wpa_ie_len > MAX_WPA_IE_LEN)
+		wpa_ie_len =3D MAX_WPA_IE_LEN;
+
+	if (down_interruptible(&priv->wpa_sem))
+		return;
+
+	/* try to use existing entry */
+	list_for_each(ptr, &priv->bss_wpa_list) {
+		bss =3D list_entry(ptr, struct islpci_bss_wpa_ie, list);
+		if (memcmp(bss->bssid, bssid, ETH_ALEN) =3D=3D 0) {
+			list_move(&bss->list, &priv->bss_wpa_list);
+			break;
+		}
+		bss =3D NULL;
+	}
+
+	if (bss =3D=3D NULL) {
+		/* add a new BSS entry; if max number of entries is already
+		 * reached, replace the least recently updated */
+		if (priv->num_bss_wpa >=3D MAX_BSS_WPA_IE_COUNT) {
+			bss =3D list_entry(priv->bss_wpa_list.prev,
+					 struct islpci_bss_wpa_ie, list);
+			list_del(&bss->list);
+		} else {
+			bss =3D kmalloc(sizeof (*bss), GFP_ATOMIC);
+			if (bss !=3D NULL) {
+				priv->num_bss_wpa++;
+				memset(bss, 0, sizeof (*bss));
+			}
+		}
+		if (bss !=3D NULL) {
+			memcpy(bss->bssid, bssid, ETH_ALEN);
+			list_add(&bss->list, &priv->bss_wpa_list);
+		}
+	}
+
+	if (bss !=3D NULL) {
+		memcpy(bss->wpa_ie, wpa_ie, wpa_ie_len);
+		bss->wpa_ie_len =3D wpa_ie_len;
+		bss->last_update =3D jiffies;
+	} else {
+		printk(KERN_DEBUG "Failed to add BSS WPA entry for " MACSTR
+		       "\n", MAC2STR(bssid));
+	}
+
+	/* expire old entries from WPA list */
+	while (priv->num_bss_wpa > 0) {
+		bss =3D list_entry(priv->bss_wpa_list.prev,
+				 struct islpci_bss_wpa_ie, list);
+		if (!time_after(jiffies, bss->last_update + 60 * HZ))
+			break;
+
+		list_del(&bss->list);
+		priv->num_bss_wpa--;
+		kfree(bss);
+	}
+
+	up(&priv->wpa_sem);
+}
+
+size_t
+prism54_wpa_ie_get(islpci_private *priv, u8 *bssid, u8 *wpa_ie)
+{
+	struct list_head *ptr;
+	struct islpci_bss_wpa_ie *bss =3D NULL;
+	size_t len =3D 0;
+
+	if (down_interruptible(&priv->wpa_sem))
+		return 0;
+
+	list_for_each(ptr, &priv->bss_wpa_list) {
+		bss =3D list_entry(ptr, struct islpci_bss_wpa_ie, list);
+		if (memcmp(bss->bssid, bssid, ETH_ALEN) =3D=3D 0)
+			break;
+		bss =3D NULL;
+	}
+	if (bss) {
+		len =3D bss->wpa_ie_len;
+		memcpy(wpa_ie, bss->wpa_ie, len);
+	}
+	up(&priv->wpa_sem);
+
+	return len;
+}
+
+void
+prism54_wpa_ie_init(islpci_private *priv)
+{
+	INIT_LIST_HEAD(&priv->bss_wpa_list);
+	sema_init(&priv->wpa_sem, 1);
+}
+
+void
+prism54_wpa_ie_clean(islpci_private *priv)
+{
+	struct list_head *ptr, *n;
+
+	list_for_each_safe(ptr, n, &priv->bss_wpa_list) {
+		struct islpci_bss_wpa_ie *bss;
+		bss =3D list_entry(ptr, struct islpci_bss_wpa_ie, list);
+		kfree(bss);
+	}
+}
+
+static void
+prism54_process_bss_data(islpci_private *priv, u32 oid, u8 *addr,
+			 u8 *payload, size_t len)
+{
+	struct ieee80211_beacon_phdr *hdr;
+	u8 *pos, *end;
+
+	if (!priv->wpa)
+		return;
+
+	hdr =3D (struct ieee80211_beacon_phdr *) payload;
+	pos =3D (u8 *) (hdr + 1);
+	end =3D payload + len;
+	while (pos < end) {
+		if (pos + 2 + pos[1] > end) {
+			printk(KERN_DEBUG "Parsing Beacon/ProbeResp failed "
+			       "for " MACSTR "\n", MAC2STR(addr));
+			return;
+		}
+		if (pos[0] =3D=3D WLAN_EID_GENERIC && pos[1] >=3D 4 &&
+		    memcmp(pos + 2, wpa_oid, 4) =3D=3D 0) {
+			prism54_wpa_ie_add(priv, addr, pos, pos[1] + 2);
+			return;
+		}
+		pos +=3D 2 + pos[1];
+	}
+}
+
+static void
+handle_request(islpci_private *priv, struct obj_mlme *mlme, enum oid_num_t=
 oid)
+{
+	if (((mlme->state =3D=3D DOT11_STATE_AUTHING) ||
+	     (mlme->state =3D=3D DOT11_STATE_ASSOCING))
+	    && mgt_mlme_answer(priv)) {
+		/* Someone is requesting auth and we must respond. Just send back
+		 * the trap with error code set accordingly.
+		 */
+		mlme->code =3D prism54_mac_accept(&priv->acl,
+						mlme->address) ? 0 : 1;
+		mgt_set_request(priv, oid, 0, mlme);
+	}
+}
+
+int
+prism54_process_trap_helper(islpci_private *priv, enum oid_num_t oid,
+			    char *data)
+{
+	struct obj_mlme *mlme =3D (struct obj_mlme *) data;
+	size_t len;
+	u8 *payload, *pos =3D (u8 *) (mlme + 1);
+
+	len =3D pos[0] | (pos[1] << 8);	/* little endian data length */
+	payload =3D pos + 2;
+
+	/* I think all trapable objects are listed here.
+	 * Some oids have a EX version. The difference is that they are emitted
+	 * in DOT11_MLME_EXTENDED mode (set with DOT11_OID_MLMEAUTOLEVEL)
+	 * with more info.
+	 * The few events already defined by the wireless tools are not really
+	 * suited. We use the more flexible custom event facility.
+	 */
+
+	/* I fear prism54_process_bss_data won't work with big endian data */
+	if ((oid =3D=3D DOT11_OID_BEACON) || (oid =3D=3D DOT11_OID_PROBE))
+		prism54_process_bss_data(priv, oid, mlme->address,
+					 payload, len);
+
+	mgt_le_to_cpu(isl_oid[oid].flags & OID_FLAG_TYPE, (void *) mlme);
+
+	switch (oid) {
+
+	case GEN_OID_LINKSTATE:
+		link_changed(priv->ndev, (u32) *data);
+		break;
+
+	case DOT11_OID_MICFAILURE:
+		send_simple_event(priv, "Mic failure");
+		break;
+
+	case DOT11_OID_DEAUTHENTICATE:
+		send_formatted_event(priv, "DeAuthenticate request", mlme, 0);
+		break;
+
+	case DOT11_OID_AUTHENTICATE:
+		handle_request(priv, mlme, oid);
+		send_formatted_event(priv, "Authenticate request", mlme, 1);
+		break;
+
+	case DOT11_OID_DISASSOCIATE:
+		send_formatted_event(priv, "Disassociate request", mlme, 0);
+		break;
+
+	case DOT11_OID_ASSOCIATE:
+		handle_request(priv, mlme, oid);
+		send_formatted_event(priv, "Associate request", mlme, 1);
+		break;
+
+	case DOT11_OID_REASSOCIATE:
+		handle_request(priv, mlme, oid);
+		send_formatted_event(priv, "ReAssociate request", mlme, 1);
+		break;
+
+	case DOT11_OID_BEACON:
+		send_formatted_event(priv,
+				     "Received a beacon from an unkown AP",
+				     mlme, 0);
+		break;
+
+	case DOT11_OID_PROBE:
+		/* we received a probe from a client. */
+		send_formatted_event(priv, "Received a probe from client", mlme,
+				     0);
+		break;
+
+		/* Note : "mlme" is actually a "struct obj_mlmeex *" here, but this
+		 * is backward compatible layout-wise with "struct obj_mlme".
+		 */
+
+	case DOT11_OID_DEAUTHENTICATEEX:
+		send_formatted_event(priv, "DeAuthenticate request", mlme, 0);
+		break;
+
+	case DOT11_OID_AUTHENTICATEEX:
+		handle_request(priv, mlme, oid);
+		send_formatted_event(priv, "Authenticate request", mlme, 1);
+		break;
+
+	case DOT11_OID_DISASSOCIATEEX:
+		send_formatted_event(priv, "Disassociate request", mlme, 0);
+		break;
+
+	case DOT11_OID_ASSOCIATEEX:
+		handle_request(priv, mlme, oid);
+		send_formatted_event(priv, "Associate request", mlme, 1);
+		break;
+
+	case DOT11_OID_REASSOCIATEEX:
+		handle_request(priv, mlme, oid);
+		send_formatted_event(priv, "Reassociate request", mlme, 1);
+		break;
+
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/*
+ * Process a device trap.  This is called via schedule_work(), outside of
+ * interrupt context, no locks held.
+ */
+void
+prism54_process_trap(void *data)
+{
+	struct islpci_mgmtframe *frame =3D data;
+	struct net_device *ndev =3D frame->ndev;
+	enum oid_num_t n =3D mgt_oidtonum(frame->header->oid);
+
+	if (n !=3D OID_NUM_LAST)
+		prism54_process_trap_helper(netdev_priv(ndev), n, frame->data);
+	islpci_mgt_release(frame);
+}
+
+int
+prism54_set_mac_address(struct net_device *ndev, void *addr)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	int ret;
+
+	if (ndev->addr_len !=3D 6)
+		return -EINVAL;
+	ret =3D mgt_set_request(priv, GEN_OID_MACADDRESS, 0,
+			      &((struct sockaddr *) addr)->sa_data);
+	if (!ret)
+		memcpy(priv->ndev->dev_addr,
+		       &((struct sockaddr *) addr)->sa_data, 6);
+
+	return ret;
+}
+
+int
+prism54_set_wpa(struct net_device *ndev, struct iw_request_info *info,
+		__u32 * uwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+
+	down_write(&priv->mib_sem);
+
+	priv->wpa =3D *uwrq;
+	if (priv->wpa) {
+		u32 l =3D DOT11_MLME_EXTENDED;
+		mgt_set(priv, DOT11_OID_MLMEAUTOLEVEL, &l);
+	}
+	/* restart the card with new level. Needed ? */
+	mgt_commit(priv);
+	up_write(&priv->mib_sem);
+
+	return 0;
+}
+
+int
+prism54_get_wpa(struct net_device *ndev, struct iw_request_info *info,
+		__u32 * uwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	*uwrq =3D priv->wpa;
+	return 0;
+}
+
+int
+prism54_set_prismhdr(struct net_device *ndev, struct iw_request_info *info,
+		     __u32 * uwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	priv->monitor_type =3D
+	    (*uwrq ? ARPHRD_IEEE80211_PRISM : ARPHRD_IEEE80211);
+	if (priv->iw_mode =3D=3D IW_MODE_MONITOR)
+		priv->ndev->type =3D priv->monitor_type;
+
+	return 0;
+}
+
+int
+prism54_get_prismhdr(struct net_device *ndev, struct iw_request_info *info,
+		     __u32 * uwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	*uwrq =3D (priv->monitor_type =3D=3D ARPHRD_IEEE80211_PRISM);
+	return 0;
+}
+
+int
+prism54_debug_oid(struct net_device *ndev, struct iw_request_info *info,
+		  __u32 * uwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+
+	priv->priv_oid =3D *uwrq;
+	printk("%s: oid 0x%08X\n", ndev->name, *uwrq);
+
+	return 0;
+}
+
+int
+prism54_debug_get_oid(struct net_device *ndev, struct iw_request_info *inf=
o,
+		      struct iw_point *data, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	struct islpci_mgmtframe *response =3D NULL;
+	int ret =3D -EIO, response_op =3D PIMFOR_OP_ERROR;
+
+	printk("%s: get_oid 0x%08X\n", ndev->name, priv->priv_oid);
+	data->length =3D 0;
+
+	if (islpci_get_state(priv) >=3D PRV_STATE_INIT) {
+		ret =3D
+		    islpci_mgt_transaction(priv->ndev, PIMFOR_OP_GET,
+					   priv->priv_oid, extra, 256,
+					   &response);
+		response_op =3D response->header->operation;
+		printk("%s: ret: %i\n", ndev->name, ret);
+		printk("%s: response_op: %i\n", ndev->name, response_op);
+		if (ret || !response
+		    || response->header->operation =3D=3D PIMFOR_OP_ERROR) {
+			if (response) {
+				islpci_mgt_release(response);
+			}
+			printk("%s: EIO\n", ndev->name);
+			ret =3D -EIO;
+		}
+		if (!ret) {
+			data->length =3D response->header->length;
+			memcpy(extra, response->data, data->length);
+			islpci_mgt_release(response);
+			printk("%s: len: %i\n", ndev->name, data->length);
+		}
+	}
+
+	return ret;
+}
+
+int
+prism54_debug_set_oid(struct net_device *ndev, struct iw_request_info *inf=
o,
+		      struct iw_point *data, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	struct islpci_mgmtframe *response =3D NULL;
+	int ret =3D 0, response_op =3D PIMFOR_OP_ERROR;
+
+	printk("%s: set_oid 0x%08X\tlen: %d\n", ndev->name, priv->priv_oid,
+	       data->length);
+
+	if (islpci_get_state(priv) >=3D PRV_STATE_INIT) {
+		ret =3D
+		    islpci_mgt_transaction(priv->ndev, PIMFOR_OP_SET,
+					   priv->priv_oid, extra, data->length,
+					   &response);
+		printk("%s: ret: %i\n", ndev->name, ret);
+		if (!ret) {
+			response_op =3D response->header->operation;
+			printk("%s: response_op: %i\n", ndev->name,
+			       response_op);
+			islpci_mgt_release(response);
+		}
+		if (ret || response_op =3D=3D PIMFOR_OP_ERROR) {
+			printk("%s: EIO\n", ndev->name);
+			ret =3D -EIO;
+		}
+	}
+
+	return (ret ? ret : -EINPROGRESS);
+}
+
+static int
+prism54_set_spy(struct net_device *ndev,
+		struct iw_request_info *info,
+		union iwreq_data *uwrq, char *extra)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	u32 u, oid =3D OID_INL_CONFIG;
+
+	down_write(&priv->mib_sem);
+	mgt_get(priv, OID_INL_CONFIG, &u);
+
+	if ((uwrq->data.length =3D=3D 0) && (priv->spy_data.spy_number > 0))
+		/* disable spy */
+		u &=3D ~INL_CONFIG_RXANNEX;
+	else if ((uwrq->data.length > 0) && (priv->spy_data.spy_number =3D=3D 0))
+		/* enable spy */
+		u |=3D INL_CONFIG_RXANNEX;
+
+	mgt_set(priv, OID_INL_CONFIG, &u);
+	mgt_commit_list(priv, &oid, 1);
+	up_write(&priv->mib_sem);
+
+	return iw_handler_set_spy(ndev, info, uwrq, extra);
+}
+
+static const iw_handler prism54_handler[] =3D {
+	(iw_handler) prism54_commit,	/* SIOCSIWCOMMIT */
+	(iw_handler) prism54_get_name,	/* SIOCGIWNAME */
+	(iw_handler) NULL,	/* SIOCSIWNWID */
+	(iw_handler) NULL,	/* SIOCGIWNWID */
+	(iw_handler) prism54_set_freq,	/* SIOCSIWFREQ */
+	(iw_handler) prism54_get_freq,	/* SIOCGIWFREQ */
+	(iw_handler) prism54_set_mode,	/* SIOCSIWMODE */
+	(iw_handler) prism54_get_mode,	/* SIOCGIWMODE */
+	(iw_handler) prism54_set_sens,	/* SIOCSIWSENS */
+	(iw_handler) prism54_get_sens,	/* SIOCGIWSENS */
+	(iw_handler) NULL,	/* SIOCSIWRANGE */
+	(iw_handler) prism54_get_range,	/* SIOCGIWRANGE */
+	(iw_handler) NULL,	/* SIOCSIWPRIV */
+	(iw_handler) NULL,	/* SIOCGIWPRIV */
+	(iw_handler) NULL,	/* SIOCSIWSTATS */
+	(iw_handler) NULL,	/* SIOCGIWSTATS */
+	prism54_set_spy,	/* SIOCSIWSPY */
+	iw_handler_get_spy,	/* SIOCGIWSPY */
+	iw_handler_set_thrspy,	/* SIOCSIWTHRSPY */
+	iw_handler_get_thrspy,	/* SIOCGIWTHRSPY */
+	(iw_handler) prism54_set_wap,	/* SIOCSIWAP */
+	(iw_handler) prism54_get_wap,	/* SIOCGIWAP */
+	(iw_handler) NULL,	/* -- hole -- */
+	(iw_handler) NULL,	/* SIOCGIWAPLIST depreciated */
+	(iw_handler) prism54_set_scan,	/* SIOCSIWSCAN */
+	(iw_handler) prism54_get_scan,	/* SIOCGIWSCAN */
+	(iw_handler) prism54_set_essid,	/* SIOCSIWESSID */
+	(iw_handler) prism54_get_essid,	/* SIOCGIWESSID */
+	(iw_handler) prism54_set_nick,	/* SIOCSIWNICKN */
+	(iw_handler) prism54_get_nick,	/* SIOCGIWNICKN */
+	(iw_handler) NULL,	/* -- hole -- */
+	(iw_handler) NULL,	/* -- hole -- */
+	(iw_handler) prism54_set_rate,	/* SIOCSIWRATE */
+	(iw_handler) prism54_get_rate,	/* SIOCGIWRATE */
+	(iw_handler) prism54_set_rts,	/* SIOCSIWRTS */
+	(iw_handler) prism54_get_rts,	/* SIOCGIWRTS */
+	(iw_handler) prism54_set_frag,	/* SIOCSIWFRAG */
+	(iw_handler) prism54_get_frag,	/* SIOCGIWFRAG */
+	(iw_handler) prism54_set_txpower,	/* SIOCSIWTXPOW */
+	(iw_handler) prism54_get_txpower,	/* SIOCGIWTXPOW */
+	(iw_handler) prism54_set_retry,	/* SIOCSIWRETRY */
+	(iw_handler) prism54_get_retry,	/* SIOCGIWRETRY */
+	(iw_handler) prism54_set_encode,	/* SIOCSIWENCODE */
+	(iw_handler) prism54_get_encode,	/* SIOCGIWENCODE */
+	(iw_handler) NULL,	/* SIOCSIWPOWER */
+	(iw_handler) NULL,	/* SIOCGIWPOWER */
+};
+
+/* The low order bit identify a SET (0) or a GET (1) ioctl.  */
+
+#define PRISM54_RESET		SIOCIWFIRSTPRIV
+#define PRISM54_GET_POLICY	SIOCIWFIRSTPRIV+1
+#define PRISM54_SET_POLICY	SIOCIWFIRSTPRIV+2
+#define PRISM54_GET_MAC		SIOCIWFIRSTPRIV+3
+#define PRISM54_ADD_MAC		SIOCIWFIRSTPRIV+4
+
+#define PRISM54_DEL_MAC		SIOCIWFIRSTPRIV+6
+
+#define PRISM54_KICK_MAC	SIOCIWFIRSTPRIV+8
+
+#define PRISM54_KICK_ALL	SIOCIWFIRSTPRIV+10
+
+#define PRISM54_GET_WPA		SIOCIWFIRSTPRIV+11
+#define PRISM54_SET_WPA		SIOCIWFIRSTPRIV+12
+
+#define PRISM54_DBG_OID		SIOCIWFIRSTPRIV+14
+#define PRISM54_DBG_GET_OID	SIOCIWFIRSTPRIV+15
+#define PRISM54_DBG_SET_OID	SIOCIWFIRSTPRIV+16
+
+#define PRISM54_GET_OID		SIOCIWFIRSTPRIV+17
+#define PRISM54_SET_OID_U32	SIOCIWFIRSTPRIV+18
+#define	PRISM54_SET_OID_STR	SIOCIWFIRSTPRIV+20
+#define	PRISM54_SET_OID_ADDR	SIOCIWFIRSTPRIV+22
+
+#define PRISM54_GET_PRISMHDR	SIOCIWFIRSTPRIV+23
+#define PRISM54_SET_PRISMHDR	SIOCIWFIRSTPRIV+24
+
+#define IWPRIV_SET_U32(n,x)	{ n, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1=
, 0, "s_"x }
+#define IWPRIV_SET_SSID(n,x)	{ n, IW_PRIV_TYPE_CHAR | IW_PRIV_SIZE_FIXED |=
 1, 0, "s_"x }
+#define IWPRIV_SET_ADDR(n,x)	{ n, IW_PRIV_TYPE_ADDR | IW_PRIV_SIZE_FIXED |=
 1, 0, "s_"x }
+#define IWPRIV_GET(n,x)	{ n, 0, IW_PRIV_TYPE_CHAR | IW_PRIV_SIZE_FIXED | P=
RIV_STR_SIZE, "g_"x }
+
+#define IWPRIV_U32(n,x)		IWPRIV_SET_U32(n,x), IWPRIV_GET(n,x)
+#define IWPRIV_SSID(n,x)	IWPRIV_SET_SSID(n,x), IWPRIV_GET(n,x)
+#define IWPRIV_ADDR(n,x)	IWPRIV_SET_ADDR(n,x), IWPRIV_GET(n,x)
+
+/* Note : limited to 128 private ioctls (wireless tools 26) */
+
+static const struct iw_priv_args prism54_private_args[] =3D {
+/*{ cmd, set_args, get_args, name } */
+	{PRISM54_RESET, 0, 0, "reset"},
+	{PRISM54_GET_PRISMHDR, 0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	 "get_prismhdr"},
+	{PRISM54_SET_PRISMHDR, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0,
+	 "set_prismhdr"},
+	{PRISM54_GET_POLICY, 0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	 "getPolicy"},
+	{PRISM54_SET_POLICY, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0,
+	 "setPolicy"},
+	{PRISM54_GET_MAC, 0, IW_PRIV_TYPE_ADDR | 64, "getMac"},
+	{PRISM54_ADD_MAC, IW_PRIV_TYPE_ADDR | IW_PRIV_SIZE_FIXED | 1, 0,
+	 "addMac"},
+	{PRISM54_DEL_MAC, IW_PRIV_TYPE_ADDR | IW_PRIV_SIZE_FIXED | 1, 0,
+	 "delMac"},
+	{PRISM54_KICK_MAC, IW_PRIV_TYPE_ADDR | IW_PRIV_SIZE_FIXED | 1, 0,
+	 "kickMac"},
+	{PRISM54_KICK_ALL, 0, 0, "kickAll"},
+	{PRISM54_GET_WPA, 0, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
+	 "get_wpa"},
+	{PRISM54_SET_WPA, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0,
+	 "set_wpa"},
+	{PRISM54_DBG_OID, IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0,
+	 "dbg_oid"},
+	{PRISM54_DBG_GET_OID, 0, IW_PRIV_TYPE_BYTE | 256, "dbg_get_oid"},
+	{PRISM54_DBG_SET_OID, IW_PRIV_TYPE_BYTE | 256, 0, "dbg_set_oid"},
+	/* --- sub-ioctls handlers --- */
+	{PRISM54_GET_OID,
+	 0, IW_PRIV_TYPE_CHAR | IW_PRIV_SIZE_FIXED | PRIV_STR_SIZE, ""},
+	{PRISM54_SET_OID_U32,
+	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, ""},
+	{PRISM54_SET_OID_STR,
+	 IW_PRIV_TYPE_CHAR | IW_PRIV_SIZE_FIXED | 1, 0, ""},
+	{PRISM54_SET_OID_ADDR,
+	 IW_PRIV_TYPE_ADDR | IW_PRIV_SIZE_FIXED | 1, 0, ""},
+	/* --- sub-ioctls definitions --- */
+	IWPRIV_ADDR(GEN_OID_MACADDRESS, "addr"),
+	IWPRIV_GET(GEN_OID_LINKSTATE, "linkstate"),
+	IWPRIV_U32(DOT11_OID_BSSTYPE, "bsstype"),
+	IWPRIV_ADDR(DOT11_OID_BSSID, "bssid"),
+	IWPRIV_U32(DOT11_OID_STATE, "state"),
+	IWPRIV_U32(DOT11_OID_AID, "aid"),
+
+	IWPRIV_SSID(DOT11_OID_SSIDOVERRIDE, "ssidoverride"),
+
+	IWPRIV_U32(DOT11_OID_MEDIUMLIMIT, "medlimit"),
+	IWPRIV_U32(DOT11_OID_BEACONPERIOD, "beacon"),
+	IWPRIV_U32(DOT11_OID_DTIMPERIOD, "dtimperiod"),
+
+	IWPRIV_U32(DOT11_OID_AUTHENABLE, "authenable"),
+	IWPRIV_U32(DOT11_OID_PRIVACYINVOKED, "privinvok"),
+	IWPRIV_U32(DOT11_OID_EXUNENCRYPTED, "exunencrypt"),
+
+	IWPRIV_U32(DOT11_OID_REKEYTHRESHOLD, "rekeythresh"),
+
+	IWPRIV_U32(DOT11_OID_MAXTXLIFETIME, "maxtxlife"),
+	IWPRIV_U32(DOT11_OID_MAXRXLIFETIME, "maxrxlife"),
+	IWPRIV_U32(DOT11_OID_ALOFT_FIXEDRATE, "fixedrate"),
+	IWPRIV_U32(DOT11_OID_MAXFRAMEBURST, "frameburst"),
+	IWPRIV_U32(DOT11_OID_PSM, "psm"),
+
+	IWPRIV_U32(DOT11_OID_BRIDGELOCAL, "bridge"),
+	IWPRIV_U32(DOT11_OID_CLIENTS, "clients"),
+	IWPRIV_U32(DOT11_OID_CLIENTSASSOCIATED, "clientassoc"),
+	IWPRIV_U32(DOT11_OID_DOT1XENABLE, "dot1xenable"),
+	IWPRIV_U32(DOT11_OID_ANTENNARX, "rxant"),
+	IWPRIV_U32(DOT11_OID_ANTENNATX, "txant"),
+	IWPRIV_U32(DOT11_OID_ANTENNADIVERSITY, "antdivers"),
+	IWPRIV_U32(DOT11_OID_EDTHRESHOLD, "edthresh"),
+	IWPRIV_U32(DOT11_OID_PREAMBLESETTINGS, "preamble"),
+	IWPRIV_GET(DOT11_OID_RATES, "rates"),
+	IWPRIV_U32(DOT11_OID_OUTPUTPOWER, ".11outpower"),
+	IWPRIV_GET(DOT11_OID_SUPPORTEDRATES, "supprates"),
+	IWPRIV_GET(DOT11_OID_SUPPORTEDFREQUENCIES, "suppfreq"),
+
+	IWPRIV_U32(DOT11_OID_NOISEFLOOR, "noisefloor"),
+	IWPRIV_GET(DOT11_OID_FREQUENCYACTIVITY, "freqactivity"),
+	IWPRIV_U32(DOT11_OID_NONERPPROTECTION, "nonerpprotec"),
+	IWPRIV_U32(DOT11_OID_PROFILES, "profile"),
+	IWPRIV_GET(DOT11_OID_EXTENDEDRATES, "extrates"),
+	IWPRIV_U32(DOT11_OID_MLMEAUTOLEVEL, "mlmelevel"),
+
+	IWPRIV_GET(DOT11_OID_BSSS, "bsss"),
+	IWPRIV_GET(DOT11_OID_BSSLIST, "bsslist"),
+	IWPRIV_U32(OID_INL_MODE, "mode"),
+	IWPRIV_U32(OID_INL_CONFIG, "config"),
+	IWPRIV_U32(OID_INL_DOT11D_CONFORMANCE, ".11dconform"),
+	IWPRIV_GET(OID_INL_PHYCAPABILITIES, "phycapa"),
+	IWPRIV_U32(OID_INL_OUTPUTPOWER, "outpower"),
+};
+
+static const iw_handler prism54_private_handler[] =3D {
+	(iw_handler) prism54_reset,
+	(iw_handler) prism54_get_policy,
+	(iw_handler) prism54_set_policy,
+	(iw_handler) prism54_get_mac,
+	(iw_handler) prism54_add_mac,
+	(iw_handler) NULL,
+	(iw_handler) prism54_del_mac,
+	(iw_handler) NULL,
+	(iw_handler) prism54_kick_mac,
+	(iw_handler) NULL,
+	(iw_handler) prism54_kick_all,
+	(iw_handler) prism54_get_wpa,
+	(iw_handler) prism54_set_wpa,
+	(iw_handler) NULL,
+	(iw_handler) prism54_debug_oid,
+	(iw_handler) prism54_debug_get_oid,
+	(iw_handler) prism54_debug_set_oid,
+	(iw_handler) prism54_get_oid,
+	(iw_handler) prism54_set_u32,
+	(iw_handler) NULL,
+	(iw_handler) prism54_set_raw,
+	(iw_handler) NULL,
+	(iw_handler) prism54_set_raw,
+	(iw_handler) prism54_get_prismhdr,
+	(iw_handler) prism54_set_prismhdr,
+};
+
+const struct iw_handler_def prism54_handler_def =3D {
+	.num_standard =3D sizeof (prism54_handler) / sizeof (iw_handler),
+	.num_private =3D sizeof (prism54_private_handler) / sizeof (iw_handler),
+	.num_private_args =3D
+	    sizeof (prism54_private_args) / sizeof (struct iw_priv_args),
+	.standard =3D (iw_handler *) prism54_handler,
+	.private =3D (iw_handler *) prism54_private_handler,
+	.private_args =3D (struct iw_priv_args *) prism54_private_args,
+	.spy_offset =3D offsetof(islpci_private, spy_data),
+};
+
+/* For ioctls that don't work with the new API */
+
+int
+prism54_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
+{
+
+	return -EOPNOTSUPP;
+}
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/p=
rism54/isl_ioctl.h linux-2.4.26-prism54/drivers/net/wireless/prism54/isl_io=
ctl.h
--- linux-2.4.26/drivers/net/wireless/prism54/isl_ioctl.h	1970-01-01 00:00:=
00.000000000 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/prism54/isl_ioctl.h	2004-07-2=
1 09:00:04.000000000 +0000
@@ -0,0 +1,54 @@
+/*
+ * =20
+ *  Copyright (C) 2002 Intersil Americas Inc.
+ *            (C) 2003 Aurelien Alleaume <slts@free.fr>
+ *            (C) 2003 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ */
+
+#ifndef _ISL_IOCTL_H
+#define _ISL_IOCTL_H
+
+#include "islpci_mgt.h"
+#include "islpci_dev.h"
+
+#include <net/iw_handler.h>	/* New driver API */
+
+#define SUPPORTED_WIRELESS_EXT                  16
+
+void prism54_mib_init(islpci_private *);
+
+struct iw_statistics *prism54_get_wireless_stats(struct net_device *);
+void prism54_update_stats(islpci_private *);
+
+void prism54_acl_init(struct islpci_acl *);
+void prism54_acl_clean(struct islpci_acl *);
+
+void prism54_process_trap(void *);
+
+void prism54_wpa_ie_init(islpci_private *priv);
+void prism54_wpa_ie_clean(islpci_private *priv);
+void prism54_wpa_ie_add(islpci_private *priv, u8 *bssid,
+			u8 *wpa_ie, size_t wpa_ie_len);
+size_t prism54_wpa_ie_get(islpci_private *priv, u8 *bssid, u8 *wpa_ie);
+
+int prism54_set_mac_address(struct net_device *, void *);
+
+int prism54_ioctl(struct net_device *, struct ifreq *, int);
+
+extern const struct iw_handler_def prism54_handler_def;
+
+#endif				/* _ISL_IOCTL_H */
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/p=
rism54/isl_oid.h linux-2.4.26-prism54/drivers/net/wireless/prism54/isl_oid.h
--- linux-2.4.26/drivers/net/wireless/prism54/isl_oid.h	1970-01-01 00:00:00=
.000000000 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/prism54/isl_oid.h	2004-07-21 =
09:00:04.000000000 +0000
@@ -0,0 +1,498 @@
+/*
+ *
+ * =20
+ *  Copyright (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
+ *  Copyright (C) 2004 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
+ *  Copyright (C) 2004 Aurelien Alleaume <slts@free.fr>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ */
+
+#if !defined(_ISL_OID_H)
+#define _ISL_OID_H
+
+/*=20
+ * MIB related constant and structure definitions for communicating
+ * with the device firmware
+ */
+
+struct obj_ssid {
+	u8 length;
+	char octets[33];
+} __attribute__ ((packed));
+
+struct obj_key {
+	u8 type;		/* dot11_priv_t */
+	u8 length;
+	char key[32];
+} __attribute__ ((packed));
+
+struct obj_mlme {
+	u8 address[6];
+	u16 id;
+	u16 state;
+	u16 code;
+} __attribute__ ((packed));
+
+struct obj_mlmeex {
+	u8 address[6];
+	u16 id;
+	u16 state;
+	u16 code;
+	u16 size;
+	u8 data[0];
+} __attribute__ ((packed));
+
+struct obj_buffer {
+	u32 size;
+	u32 addr;		/* 32bit bus address */
+} __attribute__ ((packed));
+
+struct obj_bss {
+	u8 address[6];
+	int:16;			/* padding */
+
+	char state;
+	char reserved;
+	short age;
+
+	char quality;
+	char rssi;
+
+	struct obj_ssid ssid;
+	short channel;
+	char beacon_period;
+	char dtim_period;
+	short capinfo;
+	short rates;
+	short basic_rates;
+	int:16;			/* padding */
+} __attribute__ ((packed));
+
+struct obj_bsslist {
+	u32 nr;
+	struct obj_bss bsslist[0];
+} __attribute__ ((packed));
+
+struct obj_frequencies {
+	u16 nr;
+	u16 mhz[0];
+} __attribute__ ((packed));
+
+/*=20
+ * in case everything's ok, the inlined function below will be
+ * optimized away by the compiler...
+ */
+static inline void
+__bug_on_wrong_struct_sizes(void)
+{
+	BUG_ON(sizeof (struct obj_ssid) !=3D 34);
+	BUG_ON(sizeof (struct obj_key) !=3D 34);
+	BUG_ON(sizeof (struct obj_mlme) !=3D 12);
+	BUG_ON(sizeof (struct obj_mlmeex) !=3D 14);
+	BUG_ON(sizeof (struct obj_buffer) !=3D 8);
+	BUG_ON(sizeof (struct obj_bss) !=3D 60);
+	BUG_ON(sizeof (struct obj_bsslist) !=3D 4);
+	BUG_ON(sizeof (struct obj_frequencies) !=3D 2);
+}
+
+enum dot11_state_t {
+	DOT11_STATE_NONE =3D 0,
+	DOT11_STATE_AUTHING =3D 1,
+	DOT11_STATE_AUTH =3D 2,
+	DOT11_STATE_ASSOCING =3D 3,
+
+	DOT11_STATE_ASSOC =3D 5,
+	DOT11_STATE_IBSS =3D 6,
+	DOT11_STATE_WDS =3D 7
+};
+
+enum dot11_bsstype_t {
+	DOT11_BSSTYPE_NONE =3D 0,
+	DOT11_BSSTYPE_INFRA =3D 1,
+	DOT11_BSSTYPE_IBSS =3D 2,
+	DOT11_BSSTYPE_ANY =3D 3
+};
+
+enum dot11_auth_t {
+	DOT11_AUTH_NONE =3D 0,
+	DOT11_AUTH_OS =3D 1,
+	DOT11_AUTH_SK =3D 2,
+	DOT11_AUTH_BOTH =3D 3
+};
+
+enum dot11_mlme_t {
+	DOT11_MLME_AUTO =3D 0,
+	DOT11_MLME_INTERMEDIATE =3D 1,
+	DOT11_MLME_EXTENDED =3D 2
+};
+
+enum dot11_priv_t {
+	DOT11_PRIV_WEP =3D 0,
+	DOT11_PRIV_TKIP =3D 1
+};
+
+/* Prism "Nitro" / Frameburst / "Packet Frame Grouping"
+ * Value is in microseconds. Represents the # microseconds
+ * the firmware will take to group frames before sending out then out=20
+ * together with a CSMA contention. Without this all frames are
+ * sent with a CSMA contention.=20
+ * Bibliography:=20
+ * http://www.hpl.hp.com/personal/Jean_Tourrilhes/Papers/Packet.Frame.Grou=
ping.html
+ */
+enum dot11_maxframeburst_t {=20
+	/* Values for DOT11_OID_MAXFRAMEBURST */
+	DOT11_MAXFRAMEBURST_OFF =3D 0, /* Card firmware default */
+	DOT11_MAXFRAMEBURST_MIXED_SAFE =3D 650, /* 802.11 a,b,g safe */
+	DOT11_MAXFRAMEBURST_IDEAL =3D 1300, /* Theoretical ideal level */
+	DOT11_MAXFRAMEBURST_MAX =3D 5000, /* Use this as max,
+		* Note: firmware allows for greater values. This is a
+		* recommended max. I'll update this as I find
+		* out what the real MAX is. Also note that you don't necessarily
+		* get better results with a greater value here.
+		*/
+};
+
+/* Support for 802.11 long and short frame preambles.
+ * Long	 preamble uses 128-bit sync field, 8-bit  CRC
+ * Short preamble uses 56-bit  sync field, 16-bit CRC
+ *=20
+ * 802.11a -- not sure, both optionally ?
+ * 802.11b supports long and optionally short=20
+ * 802.11g supports both */
+enum dot11_preamblesettings_t {
+	DOT11_PREAMBLESETTING_LONG =3D 0,
+		/* Allows *only* long 802.11 preambles */
+	DOT11_PREAMBLESETTING_SHORT =3D 1,
+		/* Allows *only* short 802.11 preambles */
+	DOT11_PREAMBLESETTING_DYNAMIC =3D 2
+		/* AutomatiGically set */
+};
+
+/* Support for 802.11 slot timing (time between packets).
+ *
+ * Long uses 802.11a slot timing  (9 usec ?)
+ * Short uses 802.11b slot timing (20 use ?) */
+enum dot11_slotsettings_t {
+	DOT11_SLOTSETTINGS_LONG =3D 0,=20
+		/* Allows *only* long 802.11b slot timing */
+	DOT11_SLOTSETTINGS_SHORT =3D 1,
+		/* Allows *only* long 802.11a slot timing */
+	DOT11_SLOTSETTINGS_DYNAMIC =3D 2
+		/* AutomatiGically set */
+};
+
+/* All you need to know, ERP is "Extended Rate PHY".
+ * An Extended Rate PHY (ERP) STA or AP shall support three different=20
+ * preamble and header formats:
+ * Long  preamble (refer to above)
+ * Short preamble (refer to above)
+ * OFDM  preamble ( ? )
+ *
+ * I'm assuming here Protection tells the AP
+ * to be careful, a STA which cannot handle the long pre-amble
+ * has joined.
+ */
+enum do11_nonerpstatus_t {
+	DOT11_ERPSTAT_NONEPRESENT =3D 0,
+	DOT11_ERPSTAT_USEPROTECTION =3D 1
+};
+
+/* (ERP is "Extended Rate PHY") Way to read NONERP is NON-ERP-*
+ * The key here is DOT11 NON ERP NEVER protects against
+ * NON ERP STA's. You *don't* want this unless
+ * you know what you are doing. It means you will only=20
+ * get Extended Rate capabilities */
+enum dot11_nonerpprotection_t {
+	DOT11_NONERP_NEVER =3D 0,
+	DOT11_NONERP_ALWAYS =3D 1,
+	DOT11_NONERP_DYNAMIC =3D 2
+};
+
+/* Preset OID configuration for 802.11 modes=20
+ * Note: DOT11_OID_CW[MIN|MAX] hold the values of the=20
+ * DCS MIN|MAX backoff used */
+enum dot11_profile_t { /* And set/allowed values */
+	/* Allowed values for DOT11_OID_PROFILES */
+	DOT11_PROFILE_B_ONLY =3D 0,
+		/* DOT11_OID_RATES: 1, 2, 5.5, 11Mbps=20
+		 * DOT11_OID_PREAMBLESETTINGS: DOT11_PREAMBLESETTING_DYNAMIC
+		 * DOT11_OID_CWMIN: 31
+		 * DOT11_OID_NONEPROTECTION: DOT11_NOERP_DYNAMIC
+		 * DOT11_OID_SLOTSETTINGS: DOT11_SLOTSETTINGS_LONG
+		 */
+	DOT11_PROFILE_MIXED_G_WIFI =3D 1,
+		/* DOT11_OID_RATES: 1, 2, 5.5, 11, 6, 9, 12, 18, 24, 36, 48, 54Mbs
+		 * DOT11_OID_PREAMBLESETTINGS: DOT11_PREAMBLESETTING_DYNAMIC
+		 * DOT11_OID_CWMIN: 15
+		 * DOT11_OID_NONEPROTECTION: DOT11_NOERP_DYNAMIC
+		 * DOT11_OID_SLOTSETTINGS: DOT11_SLOTSETTINGS_DYNAMIC
+		 */
+	DOT11_PROFILE_MIXED_LONG =3D 2, /* "Long range" */
+		/* Same as Profile MIXED_G_WIFI */
+	DOT11_PROFILE_G_ONLY =3D 3,
+		/* Same as Profile MIXED_G_WIFI */
+	DOT11_PROFILE_TEST =3D 4,
+		/* Same as Profile MIXED_G_WIFI except:
+		 * DOT11_OID_PREAMBLESETTINGS: DOT11_PREAMBLESETTING_SHORT
+		 * DOT11_OID_NONEPROTECTION: DOT11_NOERP_NEVER
+		 * DOT11_OID_SLOTSETTINGS: DOT11_SLOTSETTINGS_SHORT
+		 */
+	DOT11_PROFILE_B_WIFI =3D 5,
+		/* Same as Profile B_ONLY */
+	DOT11_PROFILE_A_ONLY =3D 6,
+		/* Same as Profile MIXED_G_WIFI except:
+		 * DOT11_OID_RATES: 6, 9, 12, 18, 24, 36, 48, 54Mbs
+		 */
+	DOT11_PROFILE_MIXED_SHORT =3D 7
+		/* Same as MIXED_G_WIFI */
+};
+
+
+/* The dot11d conformance level configures the 802.11d conformance levels.
+ * The following conformance levels exist:*/
+enum oid_inl_conformance_t {
+	OID_INL_CONFORMANCE_NONE =3D 0,	/* Perform active scanning */
+	OID_INL_CONFORMANCE_STRICT =3D 1,	/* Strictly adhere to 802.11d */
+	OID_INL_CONFORMANCE_FLEXIBLE =3D 2,	/* Use passed 802.11d info to
+		* determine channel AND/OR just make assumption that active=20
+		* channels are valid  channels */
+};
+
+enum oid_inl_mode_t {
+	INL_MODE_NONE =3D -1,
+	INL_MODE_PROMISCUOUS =3D 0,
+	INL_MODE_CLIENT =3D 1,
+	INL_MODE_AP =3D 2,
+	INL_MODE_SNIFFER =3D 3
+};
+
+enum oid_inl_config_t {
+	INL_CONFIG_NOTHING =3D 0x00,
+	INL_CONFIG_MANUALRUN =3D 0x01,
+	INL_CONFIG_FRAMETRAP =3D 0x02,
+	INL_CONFIG_RXANNEX =3D 0x04,
+	INL_CONFIG_TXANNEX =3D 0x08,
+	INL_CONFIG_WDS =3D 0x10
+};
+
+enum oid_inl_phycap_t {
+	INL_PHYCAP_2400MHZ =3D 1,
+	INL_PHYCAP_5000MHZ =3D 2,
+	INL_PHYCAP_FAA =3D 0x80000000,	/* Means card supports the FAA switch */
+};
+
+
+enum oid_num_t {
+	GEN_OID_MACADDRESS =3D 0,
+	GEN_OID_LINKSTATE,
+	GEN_OID_WATCHDOG,
+	GEN_OID_MIBOP,
+	GEN_OID_OPTIONS,
+	GEN_OID_LEDCONFIG,
+
+	/* 802.11 */
+	DOT11_OID_BSSTYPE,
+	DOT11_OID_BSSID,
+	DOT11_OID_SSID,
+	DOT11_OID_STATE,
+	DOT11_OID_AID,
+	DOT11_OID_COUNTRYSTRING,
+	DOT11_OID_SSIDOVERRIDE,
+
+	DOT11_OID_MEDIUMLIMIT,
+	DOT11_OID_BEACONPERIOD,
+	DOT11_OID_DTIMPERIOD,
+	DOT11_OID_ATIMWINDOW,
+	DOT11_OID_LISTENINTERVAL,
+	DOT11_OID_CFPPERIOD,
+	DOT11_OID_CFPDURATION,
+
+	DOT11_OID_AUTHENABLE,
+	DOT11_OID_PRIVACYINVOKED,
+	DOT11_OID_EXUNENCRYPTED,
+	DOT11_OID_DEFKEYID,
+	DOT11_OID_DEFKEYX,	/* DOT11_OID_DEFKEY1,...DOT11_OID_DEFKEY4 */
+	DOT11_OID_STAKEY,
+	DOT11_OID_REKEYTHRESHOLD,
+	DOT11_OID_STASC,
+
+	DOT11_OID_PRIVTXREJECTED,
+	DOT11_OID_PRIVRXPLAIN,
+	DOT11_OID_PRIVRXFAILED,
+	DOT11_OID_PRIVRXNOKEY,
+
+	DOT11_OID_RTSTHRESH,
+	DOT11_OID_FRAGTHRESH,
+	DOT11_OID_SHORTRETRIES,
+	DOT11_OID_LONGRETRIES,
+	DOT11_OID_MAXTXLIFETIME,
+	DOT11_OID_MAXRXLIFETIME,
+	DOT11_OID_AUTHRESPTIMEOUT,
+	DOT11_OID_ASSOCRESPTIMEOUT,
+
+	DOT11_OID_ALOFT_TABLE,
+	DOT11_OID_ALOFT_CTRL_TABLE,
+	DOT11_OID_ALOFT_RETREAT,
+	DOT11_OID_ALOFT_PROGRESS,
+	DOT11_OID_ALOFT_FIXEDRATE,
+	DOT11_OID_ALOFT_RSSIGRAPH,
+	DOT11_OID_ALOFT_CONFIG,
+
+	DOT11_OID_VDCFX,
+	DOT11_OID_MAXFRAMEBURST,
+
+	DOT11_OID_PSM,
+	DOT11_OID_CAMTIMEOUT,
+	DOT11_OID_RECEIVEDTIMS,
+	DOT11_OID_ROAMPREFERENCE,
+
+	DOT11_OID_BRIDGELOCAL,
+	DOT11_OID_CLIENTS,
+	DOT11_OID_CLIENTSASSOCIATED,
+	DOT11_OID_CLIENTX,	/* DOT11_OID_CLIENTX,...DOT11_OID_CLIENT2007 */
+
+	DOT11_OID_CLIENTFIND,
+	DOT11_OID_WDSLINKADD,
+	DOT11_OID_WDSLINKREMOVE,
+	DOT11_OID_EAPAUTHSTA,
+	DOT11_OID_EAPUNAUTHSTA,
+	DOT11_OID_DOT1XENABLE,
+	DOT11_OID_MICFAILURE,
+	DOT11_OID_REKEYINDICATE,
+
+	DOT11_OID_MPDUTXSUCCESSFUL,
+	DOT11_OID_MPDUTXONERETRY,
+	DOT11_OID_MPDUTXMULTIPLERETRIES,
+	DOT11_OID_MPDUTXFAILED,
+	DOT11_OID_MPDURXSUCCESSFUL,
+	DOT11_OID_MPDURXDUPS,
+	DOT11_OID_RTSSUCCESSFUL,
+	DOT11_OID_RTSFAILED,
+	DOT11_OID_ACKFAILED,
+	DOT11_OID_FRAMERECEIVES,
+	DOT11_OID_FRAMEERRORS,
+	DOT11_OID_FRAMEABORTS,
+	DOT11_OID_FRAMEABORTSPHY,
+
+	DOT11_OID_SLOTTIME,
+	DOT11_OID_CWMIN, /* MIN DCS backoff */
+	DOT11_OID_CWMAX, /* MAX DCS backoff */
+	DOT11_OID_ACKWINDOW,
+	DOT11_OID_ANTENNARX,
+	DOT11_OID_ANTENNATX,
+	DOT11_OID_ANTENNADIVERSITY,
+	DOT11_OID_CHANNEL,
+	DOT11_OID_EDTHRESHOLD,
+	DOT11_OID_PREAMBLESETTINGS,
+	DOT11_OID_RATES,
+	DOT11_OID_CCAMODESUPPORTED,
+	DOT11_OID_CCAMODE,
+	DOT11_OID_RSSIVECTOR,
+	DOT11_OID_OUTPUTPOWERTABLE,
+	DOT11_OID_OUTPUTPOWER,
+	DOT11_OID_SUPPORTEDRATES,
+	DOT11_OID_FREQUENCY,
+	DOT11_OID_SUPPORTEDFREQUENCIES,
+	DOT11_OID_NOISEFLOOR,
+	DOT11_OID_FREQUENCYACTIVITY,
+	DOT11_OID_IQCALIBRATIONTABLE,
+	DOT11_OID_NONERPPROTECTION,
+	DOT11_OID_SLOTSETTINGS,
+	DOT11_OID_NONERPTIMEOUT,
+	DOT11_OID_PROFILES,
+	DOT11_OID_EXTENDEDRATES,
+
+	DOT11_OID_DEAUTHENTICATE,
+	DOT11_OID_AUTHENTICATE,
+	DOT11_OID_DISASSOCIATE,
+	DOT11_OID_ASSOCIATE,
+	DOT11_OID_SCAN,
+	DOT11_OID_BEACON,
+	DOT11_OID_PROBE,
+	DOT11_OID_DEAUTHENTICATEEX,
+	DOT11_OID_AUTHENTICATEEX,
+	DOT11_OID_DISASSOCIATEEX,
+	DOT11_OID_ASSOCIATEEX,
+	DOT11_OID_REASSOCIATE,
+	DOT11_OID_REASSOCIATEEX,
+
+	DOT11_OID_NONERPSTATUS,
+
+	DOT11_OID_STATIMEOUT,
+	DOT11_OID_MLMEAUTOLEVEL,
+	DOT11_OID_BSSTIMEOUT,
+	DOT11_OID_ATTACHMENT,
+	DOT11_OID_PSMBUFFER,
+
+	DOT11_OID_BSSS,
+	DOT11_OID_BSSX,		/*DOT11_OID_BSS1,...,DOT11_OID_BSS64 */
+	DOT11_OID_BSSFIND,
+	DOT11_OID_BSSLIST,
+
+	OID_INL_TUNNEL,
+	OID_INL_MEMADDR,
+	OID_INL_MEMORY,
+	OID_INL_MODE,
+	OID_INL_COMPONENT_NR,
+	OID_INL_VERSION,
+	OID_INL_INTERFACE_ID,
+	OID_INL_COMPONENT_ID,
+	OID_INL_CONFIG,
+	OID_INL_DOT11D_CONFORMANCE,
+	OID_INL_PHYCAPABILITIES,
+	OID_INL_OUTPUTPOWER,
+
+	OID_NUM_LAST
+};
+
+#define OID_FLAG_CACHED		0x80
+#define OID_FLAG_TYPE		0x7f
+
+#define OID_TYPE_U32		0x01
+#define OID_TYPE_SSID		0x02
+#define OID_TYPE_KEY		0x03
+#define OID_TYPE_BUFFER		0x04
+#define OID_TYPE_BSS		0x05
+#define OID_TYPE_BSSLIST	0x06
+#define OID_TYPE_FREQUENCIES	0x07
+#define OID_TYPE_MLME		0x08
+#define OID_TYPE_MLMEEX		0x09
+#define OID_TYPE_ADDR		0x0A
+#define OID_TYPE_RAW		0x0B
+
+/* OID_TYPE_MLMEEX is special because of a variable size field when sendin=
g.
+ * Not yet implemented (not used in driver anyway).
+ */
+
+struct oid_t {
+	enum oid_num_t oid;
+	short range;		/* to define a range of oid */
+	short size;		/* max size of the associated data */
+	char flags;
+};
+
+union oid_res_t {
+	void *ptr;
+	u32 u;
+};
+
+#define	IWMAX_BITRATES	20
+#define	IWMAX_BSS	24
+#define IWMAX_FREQ	30
+#define PRIV_STR_SIZE	1024
+
+#endif				/* !defined(_ISL_OID_H) */
+/* EOF */
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/p=
rism54/islpci_dev.c linux-2.4.26-prism54/drivers/net/wireless/prism54/islpc=
i_dev.c
--- linux-2.4.26/drivers/net/wireless/prism54/islpci_dev.c	1970-01-01 00:00=
:00.000000000 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/prism54/islpci_dev.c	2004-07-=
21 09:00:04.000000000 +0000
@@ -0,0 +1,931 @@
+/*
+ * =20
+ *  Copyright (C) 2002 Intersil Americas Inc.
+ *  Copyright (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
+ *  Copyright (C) 2003 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ */
+
+#include <linux/version.h>
+#include <linux/module.h>
+
+#include <linux/netdevice.h>
+#include <linux/pci.h>
+#include <linux/etherdevice.h>
+#include <linux/delay.h>
+#include <linux/if_arp.h>
+
+#include <asm/io.h>
+
+#include "prismcompat.h"
+#include "isl_38xx.h"
+#include "isl_ioctl.h"
+#include "islpci_dev.h"
+#include "islpci_mgt.h"
+#include "islpci_eth.h"
+#include "oid_mgt.h"
+
+#define ISL3877_IMAGE_FILE	"isl3877"
+#define ISL3890_IMAGE_FILE	"isl3890"
+
+static int prism54_bring_down(islpci_private *);
+static int islpci_alloc_memory(islpci_private *);
+
+/* Temporary dummy MAC address to use until firmware is loaded.
+ * The idea there is that some tools (such as nameif) may query
+ * the MAC address before the netdev is 'open'. By using a valid
+ * OUI prefix, they can process the netdev properly.
+ * Of course, this is not the final/real MAC address. It doesn't
+ * matter, as you are suppose to be able to change it anytime via
+ * ndev->set_mac_address. Jean II */
+const unsigned char	dummy_mac[6] =3D { 0x00, 0x30, 0xB4, 0x00, 0x00, 0x00 =
};
+
+static int
+isl_upload_firmware(islpci_private *priv)
+{
+	u32 reg, rc;
+	void *device_base =3D priv->device_base;
+
+	/* clear the RAMBoot and the Reset bit */
+	reg =3D readl(device_base + ISL38XX_CTRL_STAT_REG);
+	reg &=3D ~ISL38XX_CTRL_STAT_RESET;
+	reg &=3D ~ISL38XX_CTRL_STAT_RAMBOOT;
+	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
+	wmb();
+	udelay(ISL38XX_WRITEIO_DELAY);
+
+	/* set the Reset bit without reading the register ! */
+	reg |=3D ISL38XX_CTRL_STAT_RESET;
+	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
+	wmb();
+	udelay(ISL38XX_WRITEIO_DELAY);
+
+	/* clear the Reset bit */
+	reg &=3D ~ISL38XX_CTRL_STAT_RESET;
+	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
+	wmb();
+
+	/* wait a while for the device to reboot */
+	mdelay(50);
+
+	{
+		const struct firmware *fw_entry =3D 0;
+		long fw_len;
+		const u32 *fw_ptr;
+
+		rc =3D request_firmware(&fw_entry, priv->firmware, PRISM_FW_PDEV);
+		if (rc) {
+			printk(KERN_ERR
+			       "%s: request_firmware() failed for '%s'\n",
+			       "prism54", priv->firmware);
+			return rc;
+		}
+		/* prepare the Direct Memory Base register */
+		reg =3D ISL38XX_DEV_FIRMWARE_ADDRES;
+
+		fw_ptr =3D (u32 *) fw_entry->data;
+		fw_len =3D fw_entry->size;
+
+		if (fw_len % 4) {
+			printk(KERN_ERR
+			       "%s: firmware '%s' size is not multiple of 32bit, aborting!\n",
+			       "prism54", priv->firmware);
+			release_firmware(fw_entry);
+			return EILSEQ; /* Illegal byte sequence  */;
+		}
+
+		while (fw_len > 0) {
+			long _fw_len =3D
+			    (fw_len >
+			     ISL38XX_MEMORY_WINDOW_SIZE) ?
+			    ISL38XX_MEMORY_WINDOW_SIZE : fw_len;
+			u32 *dev_fw_ptr =3D device_base + ISL38XX_DIRECT_MEM_WIN;
+
+			/* set the cards base address for writting the data */
+			isl38xx_w32_flush(device_base, reg,
+					  ISL38XX_DIR_MEM_BASE_REG);
+			wmb();	/* be paranoid */
+
+			/* increment the write address for next iteration */
+			reg +=3D _fw_len;
+			fw_len -=3D _fw_len;
+
+			/* write the data to the Direct Memory Window 32bit-wise */
+			/* memcpy_toio() doesn't guarantee 32bit writes :-| */
+			while (_fw_len > 0) {
+				/* use non-swapping writel() */
+				__raw_writel(*fw_ptr, dev_fw_ptr);
+				fw_ptr++, dev_fw_ptr++;
+				_fw_len -=3D 4;
+			}
+
+			/* flush PCI posting */
+			(void) readl(device_base + ISL38XX_PCI_POSTING_FLUSH);
+			wmb();	/* be paranoid again */
+
+			BUG_ON(_fw_len !=3D 0);
+		}
+
+		BUG_ON(fw_len !=3D 0);
+
+		release_firmware(fw_entry);
+	}
+
+	/* now reset the device
+	 * clear the Reset & ClkRun bit, set the RAMBoot bit */
+	reg =3D readl(device_base + ISL38XX_CTRL_STAT_REG);
+	reg &=3D ~ISL38XX_CTRL_STAT_CLKRUN;
+	reg &=3D ~ISL38XX_CTRL_STAT_RESET;
+	reg |=3D ISL38XX_CTRL_STAT_RAMBOOT;
+	isl38xx_w32_flush(device_base, reg, ISL38XX_CTRL_STAT_REG);
+	wmb();
+	udelay(ISL38XX_WRITEIO_DELAY);
+
+	/* set the reset bit latches the host override and RAMBoot bits
+	 * into the device for operation when the reset bit is reset */
+	reg |=3D ISL38XX_CTRL_STAT_RESET;
+	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
+	/* don't do flush PCI posting here! */
+	wmb();
+	udelay(ISL38XX_WRITEIO_DELAY);
+
+	/* clear the reset bit should start the whole circus */
+	reg &=3D ~ISL38XX_CTRL_STAT_RESET;
+	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
+	/* don't do flush PCI posting here! */
+	wmb();
+	udelay(ISL38XX_WRITEIO_DELAY);
+
+	return 0;
+}
+
+/*************************************************************************=
*****
+    Device Interrupt Handler
+**************************************************************************=
****/
+
+irqreturn_t
+islpci_interrupt(int irq, void *config, struct pt_regs *regs)
+{
+	u32 reg;
+	islpci_private *priv =3D config;
+	struct net_device *ndev =3D priv->ndev;
+	void *device =3D priv->device_base;
+	int powerstate =3D ISL38XX_PSM_POWERSAVE_STATE;
+
+	/* received an interrupt request on a shared IRQ line
+	 * first check whether the device is in sleep mode */
+	reg =3D readl(device + ISL38XX_CTRL_STAT_REG);
+	if (reg & ISL38XX_CTRL_STAT_SLEEPMODE)
+		/* device is in sleep mode, IRQ was generated by someone else */
+	{
+#if VERBOSE > SHOW_ERROR_MESSAGES
+		DEBUG(SHOW_TRACING, "Assuming someone else called the IRQ\n");
+#endif
+		return IRQ_NONE;
+	}
+
+	if (islpci_get_state(priv) !=3D PRV_STATE_SLEEP)
+		powerstate =3D ISL38XX_PSM_ACTIVE_STATE;
+
+	/* lock the interrupt handler */
+	spin_lock(&priv->slock);
+
+	/* check whether there is any source of interrupt on the device */
+	reg =3D readl(device + ISL38XX_INT_IDENT_REG);
+
+	/* also check the contents of the Interrupt Enable Register, because this
+	 * will filter out interrupt sources from other devices on the same irq !=
 */
+	reg &=3D readl(device + ISL38XX_INT_EN_REG);
+	reg &=3D ISL38XX_INT_SOURCES;
+
+	if (reg !=3D 0) {
+		/* reset the request bits in the Identification register */
+		isl38xx_w32_flush(device, reg, ISL38XX_INT_ACK_REG);
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+		DEBUG(SHOW_FUNCTION_CALLS,
+		      "IRQ: Identification register 0x%p 0x%x \n", device, reg);
+#endif
+
+		/* check for each bit in the register separately */
+		if (reg & ISL38XX_INT_IDENT_UPDATE) {
+#if VERBOSE > SHOW_ERROR_MESSAGES
+			/* Queue has been updated */
+			DEBUG(SHOW_TRACING, "IRQ: Update flag \n");
+
+			DEBUG(SHOW_QUEUE_INDEXES,
+			      "CB drv Qs: [%i][%i][%i][%i][%i][%i]\n",
+			      le32_to_cpu(priv->control_block->
+					  driver_curr_frag[0]),
+			      le32_to_cpu(priv->control_block->
+					  driver_curr_frag[1]),
+			      le32_to_cpu(priv->control_block->
+					  driver_curr_frag[2]),
+			      le32_to_cpu(priv->control_block->
+					  driver_curr_frag[3]),
+			      le32_to_cpu(priv->control_block->
+					  driver_curr_frag[4]),
+			      le32_to_cpu(priv->control_block->
+					  driver_curr_frag[5])
+			    );
+
+			DEBUG(SHOW_QUEUE_INDEXES,
+			      "CB dev Qs: [%i][%i][%i][%i][%i][%i]\n",
+			      le32_to_cpu(priv->control_block->
+					  device_curr_frag[0]),
+			      le32_to_cpu(priv->control_block->
+					  device_curr_frag[1]),
+			      le32_to_cpu(priv->control_block->
+					  device_curr_frag[2]),
+			      le32_to_cpu(priv->control_block->
+					  device_curr_frag[3]),
+			      le32_to_cpu(priv->control_block->
+					  device_curr_frag[4]),
+			      le32_to_cpu(priv->control_block->
+					  device_curr_frag[5])
+			    );
+#endif
+
+			/* cleanup the data low transmit queue */
+			islpci_eth_cleanup_transmit(priv, priv->control_block);
+
+			/* device is in active state, update the
+			 * powerstate flag if necessary */
+			powerstate =3D ISL38XX_PSM_ACTIVE_STATE;
+
+			/* check all three queues in priority order
+			 * call the PIMFOR receive function until the
+			 * queue is empty */
+			if (isl38xx_in_queue(priv->control_block,
+						ISL38XX_CB_RX_MGMTQ) !=3D 0) {
+#if VERBOSE > SHOW_ERROR_MESSAGES
+				DEBUG(SHOW_TRACING,
+				      "Received frame in Management Queue\n");
+#endif
+				islpci_mgt_receive(ndev);
+
+				islpci_mgt_cleanup_transmit(ndev);
+
+				/* Refill slots in receive queue */
+				islpci_mgmt_rx_fill(ndev);
+
+				/* no need to trigger the device, next
+                                   islpci_mgt_transaction does it */
+			}
+
+			while (isl38xx_in_queue(priv->control_block,
+						ISL38XX_CB_RX_DATA_LQ) !=3D 0) {
+#if VERBOSE > SHOW_ERROR_MESSAGES
+				DEBUG(SHOW_TRACING,
+				      "Received frame in Data Low Queue \n");
+#endif
+				islpci_eth_receive(priv);
+			}
+
+			/* check whether the data transmit queues were full */
+			if (priv->data_low_tx_full) {
+				/* check whether the transmit is not full anymore */
+				if (ISL38XX_CB_TX_QSIZE -
+				    isl38xx_in_queue(priv->control_block,
+						     ISL38XX_CB_TX_DATA_LQ) >=3D
+				    ISL38XX_MIN_QTHRESHOLD) {
+					/* nope, the driver is ready for more network frames */
+					netif_wake_queue(priv->ndev);
+
+					/* reset the full flag */
+					priv->data_low_tx_full =3D 0;
+				}
+			}
+		}
+
+		if (reg & ISL38XX_INT_IDENT_INIT) {
+			/* Device has been initialized */
+#if VERBOSE > SHOW_ERROR_MESSAGES
+			DEBUG(SHOW_TRACING,
+			      "IRQ: Init flag, device initialized \n");
+#endif
+			wake_up(&priv->reset_done);
+		}
+
+		if (reg & ISL38XX_INT_IDENT_SLEEP) {
+			/* Device intends to move to powersave state */
+#if VERBOSE > SHOW_ERROR_MESSAGES
+			DEBUG(SHOW_TRACING, "IRQ: Sleep flag \n");
+#endif
+			isl38xx_handle_sleep_request(priv->control_block,
+						     &powerstate,
+						     priv->device_base);
+		}
+
+		if (reg & ISL38XX_INT_IDENT_WAKEUP) {
+			/* Device has been woken up to active state */
+#if VERBOSE > SHOW_ERROR_MESSAGES
+			DEBUG(SHOW_TRACING, "IRQ: Wakeup flag \n");
+#endif
+
+			isl38xx_handle_wakeup(priv->control_block,
+					      &powerstate, priv->device_base);
+		}
+	}
+
+	/* sleep -> ready */
+	if (islpci_get_state(priv) =3D=3D PRV_STATE_SLEEP
+	    && powerstate =3D=3D ISL38XX_PSM_ACTIVE_STATE)
+		islpci_set_state(priv, PRV_STATE_READY);
+
+	/* !sleep -> sleep */
+	if (islpci_get_state(priv) !=3D PRV_STATE_SLEEP
+	    && powerstate =3D=3D ISL38XX_PSM_POWERSAVE_STATE)
+		islpci_set_state(priv, PRV_STATE_SLEEP);
+
+	/* unlock the interrupt handler */
+	spin_unlock(&priv->slock);
+
+	return IRQ_HANDLED;
+}
+
+/*************************************************************************=
*****
+    Network Interface Control & Statistical functions
+**************************************************************************=
****/
+static int
+islpci_open(struct net_device *ndev)
+{
+	u32 rc;
+	islpci_private *priv =3D netdev_priv(ndev);
+
+	printk(KERN_DEBUG "%s: islpci_open()\n", ndev->name);
+
+	/* reset data structures, upload firmware and reset device */
+	rc =3D islpci_reset(priv,1);
+	if (rc) {
+		prism54_bring_down(priv);
+		return rc; /* Returns informative message */
+	}
+
+	netif_start_queue(ndev);
+/*      netif_mark_up( ndev ); */
+
+	return 0;
+}
+
+static int
+islpci_close(struct net_device *ndev)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+
+	printk(KERN_DEBUG "%s: islpci_close ()\n", ndev->name);
+
+	netif_stop_queue(ndev);
+
+	return prism54_bring_down(priv);
+}
+
+static int
+prism54_bring_down(islpci_private *priv)
+{
+	void *device_base =3D priv->device_base;
+	u32 reg;
+	/* we are going to shutdown the device */
+	islpci_set_state(priv, PRV_STATE_PREBOOT);
+
+	/* disable all device interrupts in case they weren't */
+	isl38xx_disable_interrupts(priv->device_base); =20
+
+	/* For safety reasons, we may want to ensure that no DMA transfer is
+	 * currently in progress by emptying the TX and RX queues. */
+
+	/* wait until interrupts have finished executing on other CPUs */
+	prism54_synchronize_irq(priv->pdev->irq);
+
+	reg =3D readl(device_base + ISL38XX_CTRL_STAT_REG);
+	reg &=3D ~(ISL38XX_CTRL_STAT_RESET | ISL38XX_CTRL_STAT_RAMBOOT);
+	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
+	wmb();
+	udelay(ISL38XX_WRITEIO_DELAY);
+
+	reg |=3D ISL38XX_CTRL_STAT_RESET;
+	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
+	wmb();
+	udelay(ISL38XX_WRITEIO_DELAY);
+
+	/* clear the Reset bit */
+	reg &=3D ~ISL38XX_CTRL_STAT_RESET;
+	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
+	wmb();
+
+	/* wait a while for the device to reset */
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule_timeout(50*HZ/1000);
+
+	return 0;
+}
+
+static int
+islpci_upload_fw(islpci_private *priv)
+{
+	islpci_state_t old_state;
+	u32 rc;
+
+	old_state =3D islpci_set_state(priv, PRV_STATE_BOOT);
+
+	printk(KERN_DEBUG "%s: uploading firmware...\n", priv->ndev->name);
+
+	rc =3D isl_upload_firmware(priv);
+	if (rc) {
+		/* error uploading the firmware */
+		printk(KERN_ERR "%s: could not upload firmware ('%s')\n",
+		       priv->ndev->name, priv->firmware);
+
+		islpci_set_state(priv, old_state);
+		return rc;
+	}
+
+	printk(KERN_DEBUG
+	       "%s: firmware uploaded done, now triggering reset...\n",
+	       priv->ndev->name);
+
+	islpci_set_state(priv, PRV_STATE_POSTBOOT);
+
+	return 0;
+}
+
+static int
+islpci_reset_if(islpci_private *priv)
+{
+	long remaining;
+	int result =3D -ETIME;
+	int count;
+
+	DEFINE_WAIT(wait);
+	prepare_to_wait(&priv->reset_done, &wait, TASK_UNINTERRUPTIBLE);
+=09
+	/* now the last step is to reset the interface */
+	isl38xx_interface_reset(priv->device_base, priv->device_host_address);
+	islpci_set_state(priv, PRV_STATE_PREINIT);
+
+        for(count =3D 0; count < 2 && result; count++) {
+		/* The software reset acknowledge needs about 220 msec here.
+		 * Be conservative and wait for up to one second. */
+=09
+		remaining =3D schedule_timeout(HZ);
+
+		if(remaining > 0) {
+			result =3D 0;
+			break;
+		}
+
+		/* If we're here it's because our IRQ hasn't yet gone through.=20
+		 * Retry a bit more...
+		 */
+		 printk(KERN_ERR "%s: device soft reset timed out\n",
+		       priv->ndev->name);
+
+	}
+
+	finish_wait(&priv->reset_done, &wait);
+
+	if(result)
+		return result;
+
+	islpci_set_state(priv, PRV_STATE_INIT);
+
+	/* Now that the device is 100% up, let's allow
+	 * for the other interrupts --
+	 * NOTE: this is not *yet* true since we've only allowed the=20
+	 * INIT interrupt on the IRQ line. We can perhaps poll
+	 * the IRQ line until we know for sure the reset went through */
+	isl38xx_enable_common_interrupts(priv->device_base);
+
+	down_write(&priv->mib_sem);
+	mgt_commit(priv);
+	up_write(&priv->mib_sem);
+
+	islpci_set_state(priv, PRV_STATE_READY);
+
+	return 0;
+}
+
+int
+islpci_reset(islpci_private *priv, int reload_firmware)
+{
+	isl38xx_control_block *cb =3D    /* volatile not needed */
+		(isl38xx_control_block *) priv->control_block;
+	unsigned counter;
+	int rc;
+
+	if (reload_firmware)
+		islpci_set_state(priv, PRV_STATE_PREBOOT);
+	else
+		islpci_set_state(priv, PRV_STATE_POSTBOOT);
+
+	printk(KERN_DEBUG "%s: resetting device...\n", priv->ndev->name);
+
+	/* disable all device interrupts in case they weren't */
+	isl38xx_disable_interrupts(priv->device_base);
+
+	/* flush all management queues */
+	priv->index_mgmt_tx =3D 0;
+	priv->index_mgmt_rx =3D 0;
+
+	/* clear the indexes in the frame pointer */
+	for (counter =3D 0; counter < ISL38XX_CB_QCOUNT; counter++) {
+		cb->driver_curr_frag[counter] =3D cpu_to_le32(0);
+		cb->device_curr_frag[counter] =3D cpu_to_le32(0);
+	}
+
+	/* reset the mgmt receive queue */
+	for (counter =3D 0; counter < ISL38XX_CB_MGMT_QSIZE; counter++) {
+		isl38xx_fragment *frag =3D &cb->rx_data_mgmt[counter];
+		frag->size =3D cpu_to_le16(MGMT_FRAME_SIZE);
+		frag->flags =3D 0;
+		frag->address =3D cpu_to_le32(priv->mgmt_rx[counter].pci_addr);
+	}
+
+	for (counter =3D 0; counter < ISL38XX_CB_RX_QSIZE; counter++) {
+		cb->rx_data_low[counter].address =3D
+		    cpu_to_le32((u32) priv->pci_map_rx_address[counter]);
+	}
+
+	/* since the receive queues are filled with empty fragments, now we can
+	 * set the corresponding indexes in the Control Block */
+	priv->control_block->driver_curr_frag[ISL38XX_CB_RX_DATA_LQ] =3D
+	    cpu_to_le32(ISL38XX_CB_RX_QSIZE);
+	priv->control_block->driver_curr_frag[ISL38XX_CB_RX_MGMTQ] =3D
+	    cpu_to_le32(ISL38XX_CB_MGMT_QSIZE);
+
+	/* reset the remaining real index registers and full flags */
+	priv->free_data_rx =3D 0;
+	priv->free_data_tx =3D 0;
+	priv->data_low_tx_full =3D 0;
+
+	if (reload_firmware) { /* Should we load the firmware ? */
+	/* now that the data structures are cleaned up, upload
+	 * firmware and reset interface */
+		rc =3D islpci_upload_fw(priv);
+		if (rc)=20
+			return rc;
+	}
+
+	/* finally reset interface */
+	rc =3D islpci_reset_if(priv);
+	if (!rc) /* If successful */
+		return rc;
+=09
+	printk(KERN_DEBUG  "prism54: Your card/socket may be faulty, or IRQ line =
too busy :(\n");
+	return rc;
+
+}
+
+struct net_device_stats *
+islpci_statistics(struct net_device *ndev)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	DEBUG(SHOW_FUNCTION_CALLS, "islpci_statistics \n");
+#endif
+
+	return &priv->statistics;
+}
+
+/*************************************************************************=
*****
+    Network device configuration functions
+**************************************************************************=
****/
+static int
+islpci_alloc_memory(islpci_private *priv)
+{
+	int counter;
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	printk(KERN_DEBUG "islpci_alloc_memory\n");
+#endif
+
+	/* remap the PCI device base address to accessable */
+	if (!(priv->device_base =3D
+	      ioremap(pci_resource_start(priv->pdev, 0),
+		      ISL38XX_PCI_MEM_SIZE))) {
+		/* error in remapping the PCI device memory address range */
+		printk(KERN_ERR "PCI memory remapping failed \n");
+		return -1;
+	}
+
+	/* memory layout for consistent DMA region:
+	 *
+	 * Area 1: Control Block for the device interface
+	 * Area 2: Power Save Mode Buffer for temporary frame storage. Be aware t=
hat
+	 *         the number of supported stations in the AP determines the mini=
mal
+	 *         size of the buffer !
+	 */
+
+	/* perform the allocation */
+	priv->driver_mem_address =3D pci_alloc_consistent(priv->pdev,
+							HOST_MEM_BLOCK,
+							&priv->
+							device_host_address);
+
+	if (!priv->driver_mem_address) {
+		/* error allocating the block of PCI memory */
+		printk(KERN_ERR "%s: could not allocate DMA memory, aborting!",
+		       "prism54");
+		return -1;
+	}
+
+	/* assign the Control Block to the first address of the allocated area */
+	priv->control_block =3D
+	    (isl38xx_control_block *) priv->driver_mem_address;
+
+	/* set the Power Save Buffer pointer directly behind the CB */
+	priv->device_psm_buffer =3D
+		priv->device_host_address + CONTROL_BLOCK_SIZE;
+
+	/* make sure all buffer pointers are initialized */
+	for (counter =3D 0; counter < ISL38XX_CB_QCOUNT; counter++) {
+		priv->control_block->driver_curr_frag[counter] =3D cpu_to_le32(0);
+		priv->control_block->device_curr_frag[counter] =3D cpu_to_le32(0);
+	}
+
+	priv->index_mgmt_rx =3D 0;
+	memset(priv->mgmt_rx, 0, sizeof(priv->mgmt_rx));
+	memset(priv->mgmt_tx, 0, sizeof(priv->mgmt_tx));
+
+	/* allocate rx queue for management frames */
+	if (islpci_mgmt_rx_fill(priv->ndev) < 0)
+		goto out_free;
+
+	/* now get the data rx skb's */
+	memset(priv->data_low_rx, 0, sizeof (priv->data_low_rx));
+	memset(priv->pci_map_rx_address, 0, sizeof (priv->pci_map_rx_address));
+
+	for (counter =3D 0; counter < ISL38XX_CB_RX_QSIZE; counter++) {
+		struct sk_buff *skb;
+
+		/* allocate an sk_buff for received data frames storage
+		 * each frame on receive size consists of 1 fragment
+		 * include any required allignment operations */
+		if (!(skb =3D dev_alloc_skb(MAX_FRAGMENT_SIZE_RX + 2))) {
+			/* error allocating an sk_buff structure elements */
+			printk(KERN_ERR "Error allocating skb.\n");
+			skb =3D NULL;
+			goto out_free;
+		}
+		skb_reserve(skb, (4 - (long) skb->data) & 0x03);
+		/* add the new allocated sk_buff to the buffer array */
+		priv->data_low_rx[counter] =3D skb;
+
+		/* map the allocated skb data area to pci */
+		priv->pci_map_rx_address[counter] =3D
+		    pci_map_single(priv->pdev, (void *) skb->data,
+				   MAX_FRAGMENT_SIZE_RX + 2,
+				   PCI_DMA_FROMDEVICE);
+		if (!priv->pci_map_rx_address[counter]) {
+			/* error mapping the buffer to device
+			   accessable memory address */
+			printk(KERN_ERR "failed to map skb DMA'able\n");
+			goto out_free;
+		}
+	}
+
+	prism54_acl_init(&priv->acl);
+	prism54_wpa_ie_init(priv);
+	if (mgt_init(priv))=20
+		goto out_free;
+
+	return 0;
+ out_free:
+	islpci_free_memory(priv);
+	return -1;
+}
+
+int
+islpci_free_memory(islpci_private *priv)
+{
+	int counter;
+
+	if (priv->device_base)
+		iounmap(priv->device_base);
+	priv->device_base =3D 0;
+
+	/* free consistent DMA area... */
+	if (priv->driver_mem_address)
+		pci_free_consistent(priv->pdev, HOST_MEM_BLOCK,
+				    priv->driver_mem_address,
+				    priv->device_host_address);
+
+	/* clear some dangling pointers */
+	priv->driver_mem_address =3D 0;
+	priv->device_host_address =3D 0;
+	priv->device_psm_buffer =3D 0;
+	priv->control_block =3D 0;
+
+        /* clean up mgmt rx buffers */
+        for (counter =3D 0; counter < ISL38XX_CB_MGMT_QSIZE; counter++) {
+		struct islpci_membuf *buf =3D &priv->mgmt_rx[counter];
+		if (buf->pci_addr)
+			pci_unmap_single(priv->pdev, buf->pci_addr,
+					 buf->size, PCI_DMA_FROMDEVICE);
+		buf->pci_addr =3D 0;
+		if (buf->mem)
+			kfree(buf->mem);
+		buf->size =3D 0;
+		buf->mem =3D NULL;
+        }
+
+	/* clean up data rx buffers */
+	for (counter =3D 0; counter < ISL38XX_CB_RX_QSIZE; counter++) {
+		if (priv->pci_map_rx_address[counter])
+			pci_unmap_single(priv->pdev,
+					 priv->pci_map_rx_address[counter],
+					 MAX_FRAGMENT_SIZE_RX + 2,
+					 PCI_DMA_FROMDEVICE);
+		priv->pci_map_rx_address[counter] =3D 0;
+
+		if (priv->data_low_rx[counter])
+			dev_kfree_skb(priv->data_low_rx[counter]);
+		priv->data_low_rx[counter] =3D 0;
+	}
+
+	/* Free the acces control list and the WPA list */
+	prism54_acl_clean(&priv->acl);
+	prism54_wpa_ie_clean(priv);
+	mgt_clean(priv);
+
+	return 0;
+}
+
+#if 0
+static void
+islpci_set_multicast_list(struct net_device *dev)
+{
+	/* put device into promisc mode and let network layer handle it */
+}
+#endif
+
+struct net_device *
+islpci_setup(struct pci_dev *pdev)
+{
+	islpci_private *priv;
+	struct net_device *ndev =3D alloc_etherdev(sizeof (islpci_private));
+
+	if (!ndev)
+		return ndev;
+
+	SET_MODULE_OWNER(ndev);
+	pci_set_drvdata(pdev, ndev);
+#if defined(SET_NETDEV_DEV)
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+#endif
+
+	/* setup the structure members */
+	ndev->base_addr =3D pci_resource_start(pdev, 0);
+	ndev->irq =3D pdev->irq;
+
+	/* initialize the function pointers */
+	ndev->open =3D &islpci_open;
+	ndev->stop =3D &islpci_close;
+	ndev->get_stats =3D &islpci_statistics;
+	ndev->get_wireless_stats =3D &prism54_get_wireless_stats;
+	ndev->do_ioctl =3D &prism54_ioctl;
+	ndev->wireless_handlers =3D
+	    (struct iw_handler_def *) &prism54_handler_def;
+
+	ndev->hard_start_xmit =3D &islpci_eth_transmit;
+	/* ndev->set_multicast_list =3D &islpci_set_multicast_list; */
+	ndev->addr_len =3D ETH_ALEN;
+	ndev->set_mac_address =3D &prism54_set_mac_address;
+	/* Get a non-zero dummy MAC address for nameif. Jean II */
+	memcpy(ndev->dev_addr, dummy_mac, 6);
+
+#ifdef HAVE_TX_TIMEOUT
+	ndev->watchdog_timeo =3D ISLPCI_TX_TIMEOUT;
+	ndev->tx_timeout =3D &islpci_eth_tx_timeout;
+#endif
+
+	/* allocate a private device structure to the network device  */
+	priv =3D netdev_priv(ndev);
+	priv->ndev =3D ndev;
+	priv->pdev =3D pdev;
+	priv->monitor_type =3D ARPHRD_IEEE80211;
+	priv->ndev->type =3D (priv->iw_mode =3D=3D IW_MODE_MONITOR) ?
+		priv->monitor_type : ARPHRD_ETHER;
+
+	/* save the start and end address of the PCI memory area */
+	ndev->mem_start =3D (unsigned long) priv->device_base;
+	ndev->mem_end =3D ndev->mem_start + ISL38XX_PCI_MEM_SIZE;
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	DEBUG(SHOW_TRACING, "PCI Memory remapped to 0x%p\n", priv->device_base);
+#endif
+
+	init_waitqueue_head(&priv->reset_done);
+
+	/* init the queue read locks, process wait counter */
+	sema_init(&priv->mgmt_sem, 1);
+	priv->mgmt_received =3D NULL;
+	init_waitqueue_head(&priv->mgmt_wqueue);
+	sema_init(&priv->stats_sem, 1);
+	spin_lock_init(&priv->slock);
+
+	/* init state machine with off#1 state */
+	priv->state =3D PRV_STATE_OFF;
+	priv->state_off =3D 1;
+
+	/* initialize workqueue's */
+	INIT_WORK(&priv->stats_work,
+		  (void (*)(void *)) prism54_update_stats, priv);
+	priv->stats_timestamp =3D 0;
+
+	INIT_WORK(&priv->reset_task, islpci_do_reset_and_wake, priv);
+	priv->reset_task_pending =3D 0;
+
+	/* allocate various memory areas */
+	if (islpci_alloc_memory(priv))
+		goto do_free_netdev;
+
+	/* select the firmware file depending on the device id */
+	switch (pdev->device) {
+	case PCIDEVICE_ISL3890:
+	case PCIDEVICE_3COM6001:
+		strcpy(priv->firmware, ISL3890_IMAGE_FILE);
+		break;
+	case PCIDEVICE_ISL3877:
+		strcpy(priv->firmware, ISL3877_IMAGE_FILE);
+		break;
+
+	default:
+		strcpy(priv->firmware, ISL3890_IMAGE_FILE);
+		break;
+	}
+
+	if (register_netdev(ndev)) {
+		DEBUG(SHOW_ERROR_MESSAGES,
+		      "ERROR: register_netdev() failed \n");
+		goto do_islpci_free_memory;
+	}
+
+	return ndev;
+
+      do_islpci_free_memory:
+	islpci_free_memory(priv);
+      do_free_netdev:
+	pci_set_drvdata(pdev, 0);
+	free_netdev(ndev);
+	priv =3D 0;
+	return NULL;
+}
+
+islpci_state_t
+islpci_set_state(islpci_private *priv, islpci_state_t new_state)
+{
+	islpci_state_t old_state;
+
+	/* lock */
+	old_state =3D priv->state;
+
+	/* this means either a race condition or some serious error in
+	 * the driver code */
+	switch (new_state) {
+	case PRV_STATE_OFF:
+		priv->state_off++;
+	default:
+		priv->state =3D new_state;
+		break;
+
+	case PRV_STATE_PREBOOT:
+		/* there are actually many off-states, enumerated by
+		 * state_off */
+		if (old_state =3D=3D PRV_STATE_OFF)
+			priv->state_off--;
+
+		/* only if hw_unavailable is zero now it means we either
+		 * were in off#1 state, or came here from
+		 * somewhere else */
+		if (!priv->state_off)
+			priv->state =3D new_state;
+		break;
+	};
+#if 0
+	printk(KERN_DEBUG "%s: state transition %d -> %d (off#%d)\n",
+	       priv->ndev->name, old_state, new_state, priv->state_off);
+#endif
+
+	/* invariants */
+	BUG_ON(priv->state_off < 0);
+	BUG_ON(priv->state_off && (priv->state !=3D PRV_STATE_OFF));
+	BUG_ON(!priv->state_off && (priv->state =3D=3D PRV_STATE_OFF));
+
+	/* unlock */
+	return old_state;
+}
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/p=
rism54/islpci_dev.h linux-2.4.26-prism54/drivers/net/wireless/prism54/islpc=
i_dev.h
--- linux-2.4.26/drivers/net/wireless/prism54/islpci_dev.h	1970-01-01 00:00=
:00.000000000 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/prism54/islpci_dev.h	2004-07-=
21 09:00:04.000000000 +0000
@@ -0,0 +1,215 @@
+/*
+ * =20
+ *  Copyright (C) 2002 Intersil Americas Inc.=20
+ *  Copyright (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
+ *  Copyright (C) 2003 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
+ *  Copyright (C) 2003 Aurelien Alleaume <slts@free.fr>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ */
+
+#ifndef _ISLPCI_DEV_H
+#define _ISLPCI_DEV_H
+
+#include <linux/version.h>
+#include <linux/netdevice.h>
+#include <linux/wireless.h>
+#include <net/iw_handler.h>
+#include <linux/list.h>
+
+#include "isl_38xx.h"
+#include "isl_oid.h"
+#include "islpci_mgt.h"
+
+/* some states might not be superflous and may be removed when
+   design is finalized (hvr) */
+typedef enum {
+	PRV_STATE_OFF =3D 0,	/* this means hw_unavailable is !=3D 0 */
+	PRV_STATE_PREBOOT,	/* we are in a pre-boot state (empty RAM) */
+	PRV_STATE_BOOT,		/* boot state (fw upload, run fw) */
+	PRV_STATE_POSTBOOT,	/* after boot state, need reset now */
+	PRV_STATE_PREINIT,	/* pre-init state */
+	PRV_STATE_INIT,		/* init state (restore MIB backup to device) */
+	PRV_STATE_READY,	/* driver&device are in operational state */
+	PRV_STATE_SLEEP		/* device in sleep mode */
+} islpci_state_t;
+
+/* ACL using MAC address */
+struct mac_entry {
+   struct list_head _list;
+   char addr[ETH_ALEN];
+};
+
+struct islpci_acl {
+   enum { MAC_POLICY_OPEN=3D0, MAC_POLICY_ACCEPT=3D1, MAC_POLICY_REJECT=3D=
2 } policy;
+   struct list_head mac_list;  /* a list of mac_entry */
+   int size;   /* size of queue */
+   struct semaphore sem;   /* accessed in ioctls and trap_work */
+};
+
+struct islpci_membuf {
+	int size;                   /* size of memory */
+	void *mem;                  /* address of memory as seen by CPU */
+	dma_addr_t pci_addr;        /* address of memory as seen by device */
+};
+
+#define MAX_BSS_WPA_IE_COUNT 64
+#define MAX_WPA_IE_LEN 64
+struct islpci_bss_wpa_ie {
+	struct list_head list;
+	unsigned long last_update;
+	u8 bssid[ETH_ALEN];
+	u8 wpa_ie[MAX_WPA_IE_LEN];
+	size_t wpa_ie_len;
+=09
+};
+
+typedef struct {
+	spinlock_t slock;	/* generic spinlock; */
+=09
+	u32 priv_oid;
+
+	/* our mib cache */
+	u32 iw_mode;
+        struct rw_semaphore mib_sem;
+	void **mib;
+	char nickname[IW_ESSID_MAX_SIZE+1];
+=09
+	/* Take care of the wireless stats */
+	struct work_struct stats_work;
+	struct semaphore stats_sem;
+	/* remember when we last updated the stats */
+	unsigned long stats_timestamp;
+	/* The first is accessed under semaphore locking.
+	 * The second is the clean one we return to iwconfig.
+	 */
+	struct iw_statistics local_iwstatistics;
+	struct iw_statistics iwstatistics;
+
+	struct iw_spy_data spy_data; /* iwspy support */
+
+	int monitor_type; /* ARPHRD_IEEE80211 or ARPHRD_IEEE80211_PRISM */
+
+	struct islpci_acl acl;
+
+	/* PCI bus allocation & configuration members */
+	struct pci_dev *pdev;	/* PCI structure information */
+	u32 pci_state[16];	/* used for suspend/resume */
+	char firmware[33];
+
+	void *device_base;	/* ioremapped device base address */
+
+	/* consistent DMA region */
+	void *driver_mem_address;	/* base DMA address */
+	dma_addr_t device_host_address;	/* base DMA address (bus address) */
+	dma_addr_t device_psm_buffer;	/* host memory for PSM buffering (bus addre=
ss) */
+
+	/* our network_device structure  */
+	struct net_device *ndev;
+
+	/* device queue interface members */
+	struct isl38xx_cb *control_block;	/* device control block=20
+							   (=3D=3D driver_mem_address!) */
+
+	/* Each queue has three indexes:
+	 *   free/index_mgmt/data_rx/tx (called index, see below),
+	 *   driver_curr_frag, and device_curr_frag (in the control block)
+	 * All indexes are ever-increasing, but interpreted modulo the
+	 * device queue size when used.
+	 *   index <=3D device_curr_frag <=3D driver_curr_frag  at all times
+	 * For rx queues, [index, device_curr_frag) contains fragments
+	 * that the interrupt processing needs to handle (owned by driver).
+	 * [device_curr_frag, driver_curr_frag) is the free space in the
+	 * rx queue, waiting for data (owned by device).  The driver
+	 * increments driver_curr_frag to indicate to the device that more
+	 * buffers are available.
+	 * If device_curr_frag =3D=3D driver_curr_frag, no more rx buffers are
+	 * available, and the rx DMA engine of the device is halted.
+	 * For tx queues, [index, device_curr_frag) contains fragments
+	 * where tx is done; they need to be freed (owned by driver).
+	 * [device_curr_frag, driver_curr_frag) contains the frames
+	 * that are being transferred (owned by device).  The driver
+	 * increments driver_curr_frag to indicate that more tx work
+	 * needs to be done.
+	 */
+	u32 index_mgmt_rx;              /* real index mgmt rx queue */
+	u32 index_mgmt_tx;              /* read index mgmt tx queue */
+	u32 free_data_rx;	/* free pointer data rx queue */
+	u32 free_data_tx;	/* free pointer data tx queue */
+	u32 data_low_tx_full;	/* full detected flag */
+
+	/* frame memory buffers for the device queues */
+	struct islpci_membuf mgmt_tx[ISL38XX_CB_MGMT_QSIZE];
+	struct islpci_membuf mgmt_rx[ISL38XX_CB_MGMT_QSIZE];
+	struct sk_buff *data_low_tx[ISL38XX_CB_TX_QSIZE];
+	struct sk_buff *data_low_rx[ISL38XX_CB_RX_QSIZE];
+	dma_addr_t pci_map_tx_address[ISL38XX_CB_TX_QSIZE];
+	dma_addr_t pci_map_rx_address[ISL38XX_CB_RX_QSIZE];
+
+	/* driver network interface members */
+	struct net_device_stats statistics;
+
+	/* wait for a reset interrupt */
+	wait_queue_head_t reset_done;
+
+	/* used by islpci_mgt_transaction */
+	struct semaphore mgmt_sem; /* serialize access to mailbox and wqueue */
+	struct islpci_mgmtframe *mgmt_received;	  /* mbox for incoming frame */
+	wait_queue_head_t mgmt_wqueue;            /* waitqueue for mbox */
+
+	/* state machine */
+	islpci_state_t state;
+	int state_off;		/* enumeration of off-state, if 0 then
+				 * we're not in any off-state */
+
+	/* WPA stuff */
+	int wpa; /* WPA mode enabled */
+	struct list_head bss_wpa_list;
+	int num_bss_wpa;
+	struct semaphore wpa_sem;
+
+	struct work_struct reset_task;
+	int reset_task_pending;
+} islpci_private;
+
+static inline islpci_state_t
+islpci_get_state(islpci_private *priv)
+{
+	/* lock */
+	return priv->state;
+	/* unlock */
+}
+
+islpci_state_t islpci_set_state(islpci_private *priv, islpci_state_t new_s=
tate);
+
+#define ISLPCI_TX_TIMEOUT               (2*HZ)
+
+irqreturn_t islpci_interrupt(int, void *, struct pt_regs *);
+
+int prism54_post_setup(islpci_private *, int);
+int islpci_reset(islpci_private *, int);
+
+static inline void
+islpci_trigger(islpci_private *priv)
+{
+	isl38xx_trigger_device(islpci_get_state(priv) =3D=3D PRV_STATE_SLEEP,
+			       priv->device_base);
+}
+
+struct net_device_stats *islpci_statistics(struct net_device *);
+
+int islpci_free_memory(islpci_private *);
+struct net_device *islpci_setup(struct pci_dev *);
+#endif				/* _ISLPCI_DEV_H */
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/p=
rism54/islpci_eth.c linux-2.4.26-prism54/drivers/net/wireless/prism54/islpc=
i_eth.c
--- linux-2.4.26/drivers/net/wireless/prism54/islpci_eth.c	1970-01-01 00:00=
:00.000000000 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/prism54/islpci_eth.c	2004-07-=
21 09:00:04.000000000 +0000
@@ -0,0 +1,518 @@
+/*
+ * =20
+ *  Copyright (C) 2002 Intersil Americas Inc.
+ *  Copyright (C) 2004 Aurelien Alleaume <slts@free.fr>
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ */
+
+#include <linux/version.h>
+#include <linux/module.h>
+
+#include <linux/pci.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/if_arp.h>
+
+#include "prismcompat.h"
+#include "isl_38xx.h"
+#include "islpci_eth.h"
+#include "islpci_mgt.h"
+#include "oid_mgt.h"
+
+/*************************************************************************=
*****
+    Network Interface functions
+**************************************************************************=
****/
+void
+islpci_eth_cleanup_transmit(islpci_private *priv,
+			    isl38xx_control_block *control_block)
+{
+	struct sk_buff *skb;
+	u32 index;
+
+	/* compare the control block read pointer with the free pointer */
+	while (priv->free_data_tx !=3D
+	       le32_to_cpu(control_block->
+			   device_curr_frag[ISL38XX_CB_TX_DATA_LQ])) {
+		/* read the index of the first fragment to be freed */
+		index =3D priv->free_data_tx % ISL38XX_CB_TX_QSIZE;
+
+		/* check for holes in the arrays caused by multi fragment frames=20
+		 * searching for the last fragment of a frame */
+		if (priv->pci_map_tx_address[index] !=3D (dma_addr_t) NULL) {
+			/* entry is the last fragment of a frame
+			 * free the skb structure and unmap pci memory */
+			skb =3D priv->data_low_tx[index];
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+			DEBUG(SHOW_TRACING,
+			      "cleanup skb %p skb->data %p skb->len %u truesize %u\n ",
+			      skb, skb->data, skb->len, skb->truesize);
+#endif
+
+			pci_unmap_single(priv->pdev,
+					 priv->pci_map_tx_address[index],
+					 skb->len, PCI_DMA_TODEVICE);
+			dev_kfree_skb_irq(skb);
+			skb =3D NULL;
+		}
+		/* increment the free data low queue pointer */
+		priv->free_data_tx++;
+	}
+}
+
+int
+islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	isl38xx_control_block *cb =3D priv->control_block;
+	u32 index;
+	dma_addr_t pci_map_address;
+	int frame_size;
+	isl38xx_fragment *fragment;
+	int offset;
+	struct sk_buff *newskb;
+	int newskb_offset;
+	unsigned long flags;
+	unsigned char wds_mac[6];
+	u32 curr_frag;
+	int err =3D 0;
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	DEBUG(SHOW_FUNCTION_CALLS, "islpci_eth_transmit \n");
+#endif
+
+	/* lock the driver code */
+	spin_lock_irqsave(&priv->slock, flags);
+
+	/* determine the amount of fragments needed to store the frame */
+
+	frame_size =3D skb->len < ETH_ZLEN ? ETH_ZLEN : skb->len;
+	if (init_wds)
+		frame_size +=3D 6;
+
+	/* check whether the destination queue has enough fragments for the frame=
 */
+	curr_frag =3D le32_to_cpu(cb->driver_curr_frag[ISL38XX_CB_TX_DATA_LQ]);
+	if (unlikely(curr_frag - priv->free_data_tx >=3D ISL38XX_CB_TX_QSIZE)) {
+		printk(KERN_ERR "%s: transmit device queue full when awake\n",
+		       ndev->name);
+		netif_stop_queue(ndev);
+
+		/* trigger the device */
+		isl38xx_w32_flush(priv->device_base, ISL38XX_DEV_INT_UPDATE,
+				  ISL38XX_DEV_INT_REG);
+		udelay(ISL38XX_WRITEIO_DELAY);
+
+		err =3D -EBUSY;
+		goto drop_free;
+	}
+	/* Check alignment and WDS frame formatting. The start of the packet shou=
ld
+	 * be aligned on a 4-byte boundary. If WDS is enabled add another 6 bytes
+	 * and add WDS address information */
+	if (likely(((long) skb->data & 0x03) | init_wds)) {
+		/* get the number of bytes to add and re-allign */
+		offset =3D (4 - (long) skb->data) & 0x03;
+		offset +=3D init_wds ? 6 : 0;
+
+		/* check whether the current skb can be used  */
+		if (!skb_cloned(skb) && (skb_tailroom(skb) >=3D offset)) {
+			unsigned char *src =3D skb->data;
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+			DEBUG(SHOW_TRACING, "skb offset %i wds %i\n", offset,
+			      init_wds);
+#endif
+
+			/* align the buffer on 4-byte boundary */
+			skb_reserve(skb, (4 - (long) skb->data) & 0x03);
+			if (init_wds) {
+				/* wds requires an additional address field of 6 bytes */
+				skb_put(skb, 6);
+#ifdef ISLPCI_ETH_DEBUG
+				printk("islpci_eth_transmit:wds_mac\n");
+#endif
+				memmove(skb->data + 6, src, skb->len);
+				memcpy(skb->data, wds_mac, 6);
+			} else {
+				memmove(skb->data, src, skb->len);
+			}
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+			DEBUG(SHOW_TRACING, "memmove %p %p %i \n", skb->data,
+			      src, skb->len);
+#endif
+		} else {
+			newskb =3D
+			    dev_alloc_skb(init_wds ? skb->len + 6 : skb->len);
+			if (unlikely(newskb =3D=3D NULL)) {
+				printk(KERN_ERR "%s: Cannot allocate skb\n",
+				       ndev->name);
+				err =3D -ENOMEM;
+				goto drop_free;
+			}
+			newskb_offset =3D (4 - (long) newskb->data) & 0x03;
+
+			/* Check if newskb->data is aligned */
+			if (newskb_offset)
+				skb_reserve(newskb, newskb_offset);
+
+			skb_put(newskb, init_wds ? skb->len + 6 : skb->len);
+			if (init_wds) {
+				memcpy(newskb->data + 6, skb->data, skb->len);
+				memcpy(newskb->data, wds_mac, 6);
+#ifdef ISLPCI_ETH_DEBUG
+				printk("islpci_eth_transmit:wds_mac\n");
+#endif
+			} else
+				memcpy(newskb->data, skb->data, skb->len);
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+			DEBUG(SHOW_TRACING, "memcpy %p %p %i wds %i\n",
+			      newskb->data, skb->data, skb->len, init_wds);
+#endif
+
+			newskb->dev =3D skb->dev;
+			dev_kfree_skb(skb);
+			skb =3D newskb;
+		}
+	}
+	/* display the buffer contents for debugging */
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	DEBUG(SHOW_BUFFER_CONTENTS, "\ntx %p ", skb->data);
+	display_buffer((char *) skb->data, skb->len);
+#endif
+
+	/* map the skb buffer to pci memory for DMA operation */
+	pci_map_address =3D pci_map_single(priv->pdev,
+					 (void *) skb->data, skb->len,
+					 PCI_DMA_TODEVICE);
+	if (unlikely(pci_map_address =3D=3D 0)) {
+		printk(KERN_WARNING "%s: cannot map buffer to PCI\n",
+		       ndev->name);
+
+		err =3D -EIO;
+		goto drop_free;
+	}
+	/* Place the fragment in the control block structure. */
+	index =3D curr_frag % ISL38XX_CB_TX_QSIZE;
+	fragment =3D &cb->tx_data_low[index];
+
+	priv->pci_map_tx_address[index] =3D pci_map_address;
+	/* store the skb address for future freeing  */
+	priv->data_low_tx[index] =3D skb;
+	/* set the proper fragment start address and size information */
+	fragment->size =3D cpu_to_le16(frame_size);
+	fragment->flags =3D cpu_to_le16(0);	/* set to 1 if more fragments */
+	fragment->address =3D cpu_to_le32(pci_map_address);
+	curr_frag++;
+
+	/* The fragment address in the control block must have been
+	 * written before announcing the frame buffer to device. */
+	wmb();
+	cb->driver_curr_frag[ISL38XX_CB_TX_DATA_LQ] =3D cpu_to_le32(curr_frag);
+
+	if (curr_frag - priv->free_data_tx + ISL38XX_MIN_QTHRESHOLD
+	    > ISL38XX_CB_TX_QSIZE) {
+		/* stop sends from upper layers */
+		netif_stop_queue(ndev);
+
+		/* set the full flag for the transmission queue */
+		priv->data_low_tx_full =3D 1;
+	}
+
+	/* trigger the device */
+	islpci_trigger(priv);
+
+	/* unlock the driver code */
+	spin_unlock_irqrestore(&priv->slock, flags);
+
+	/* set the transmission time */
+	ndev->trans_start =3D jiffies;
+	priv->statistics.tx_packets++;
+	priv->statistics.tx_bytes +=3D skb->len;
+
+	return 0;
+
+      drop_free:
+	/* free the skbuf structure before aborting */
+	dev_kfree_skb(skb);
+	skb =3D NULL;
+
+	priv->statistics.tx_dropped++;
+	spin_unlock_irqrestore(&priv->slock, flags);
+	return err;
+}
+
+static inline int
+islpci_monitor_rx(islpci_private *priv, struct sk_buff **skb)
+{
+	/* The card reports full 802.11 packets but with a 20 bytes
+	 * header and without the FCS. But there a is a bit that
+	 * indicates if the packet is corrupted :-) */
+	struct rfmon_header *hdr =3D (struct rfmon_header *) (*skb)->data;
+	if (hdr->flags & 0x01)
+		/* This one is bad. Drop it ! */
+		return -1;
+	if (priv->ndev->type =3D=3D ARPHRD_IEEE80211_PRISM) {
+		struct avs_80211_1_header *avs;
+		/* extract the relevant data from the header */
+		u32 clock =3D le32_to_cpu(hdr->clock);
+		u8 rate =3D hdr->rate;
+		u16 freq =3D le16_to_cpu(hdr->freq);
+		u8 rssi =3D hdr->rssi;
+
+		skb_pull(*skb, sizeof (struct rfmon_header));
+
+		if (skb_headroom(*skb) < sizeof (struct avs_80211_1_header)) {
+			struct sk_buff *newskb =3D skb_copy_expand(*skb,
+								 sizeof (struct
+									 avs_80211_1_header),
+								 0, GFP_ATOMIC);
+			if (newskb) {
+				dev_kfree_skb_irq(*skb);
+				*skb =3D newskb;
+			} else
+				return -1;
+			/* This behavior is not very subtile... */
+		}
+
+		/* make room for the new header and fill it. */
+		avs =3D
+		    (struct avs_80211_1_header *) skb_push(*skb,
+							   sizeof (struct
+								   avs_80211_1_header));
+	=09
+		avs->version =3D cpu_to_be32(P80211CAPTURE_VERSION);
+		avs->length =3D cpu_to_be32(sizeof (struct avs_80211_1_header));
+		avs->mactime =3D cpu_to_be64(le64_to_cpu(clock));
+		avs->hosttime =3D cpu_to_be64(jiffies);
+		avs->phytype =3D cpu_to_be32(6);	/*OFDM: 6 for (g), 8 for (a) */
+		avs->channel =3D cpu_to_be32(channel_of_freq(freq));
+		avs->datarate =3D cpu_to_be32(rate * 5);
+		avs->antenna =3D cpu_to_be32(0);	/*unknown */
+		avs->priority =3D cpu_to_be32(0);	/*unknown */
+		avs->ssi_type =3D cpu_to_be32(3);	/*2: dBm, 3: raw RSSI */
+		avs->ssi_signal =3D cpu_to_be32(rssi & 0x7f);
+		avs->ssi_noise =3D cpu_to_be32(priv->local_iwstatistics.qual.noise);	/*b=
etter than 'undefined', I assume */
+		avs->preamble =3D cpu_to_be32(0);	/*unknown */
+		avs->encoding =3D cpu_to_be32(0);	/*unknown */
+	} else
+		skb_pull(*skb, sizeof (struct rfmon_header));
+
+	(*skb)->protocol =3D htons(ETH_P_802_2);
+	(*skb)->mac.raw =3D (*skb)->data;
+	(*skb)->pkt_type =3D PACKET_OTHERHOST;
+
+	return 0;
+}
+
+int
+islpci_eth_receive(islpci_private *priv)
+{
+	struct net_device *ndev =3D priv->ndev;
+	isl38xx_control_block *control_block =3D priv->control_block;
+	struct sk_buff *skb;
+	u16 size;
+	u32 index, offset;
+	unsigned char *src;
+	int discard =3D 0;
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	DEBUG(SHOW_FUNCTION_CALLS, "islpci_eth_receive \n");
+#endif
+
+	/* the device has written an Ethernet frame in the data area
+	 * of the sk_buff without updating the structure, do it now */
+	index =3D priv->free_data_rx % ISL38XX_CB_RX_QSIZE;
+	size =3D le16_to_cpu(control_block->rx_data_low[index].size);
+	skb =3D priv->data_low_rx[index];
+	offset =3D ((unsigned long)
+		  le32_to_cpu(control_block->rx_data_low[index].address) -
+		  (unsigned long) skb->data) & 3;
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	DEBUG(SHOW_TRACING,
+	      "frq->addr %x skb->data %p skb->len %u offset %u truesize %u\n ",
+	      control_block->rx_data_low[priv->free_data_rx].address, skb->data,
+	      skb->len, offset, skb->truesize);
+#endif
+
+	/* delete the streaming DMA mapping before processing the skb */
+	pci_unmap_single(priv->pdev,
+			 priv->pci_map_rx_address[index],
+			 MAX_FRAGMENT_SIZE_RX + 2, PCI_DMA_FROMDEVICE);
+
+	/* update the skb structure and allign the buffer */
+	skb_put(skb, size);
+	if (offset) {
+		/* shift the buffer allocation offset bytes to get the right frame */
+		skb_pull(skb, 2);
+		skb_put(skb, 2);
+	}
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	/* display the buffer contents for debugging */
+	DEBUG(SHOW_BUFFER_CONTENTS, "\nrx %p ", skb->data);
+	display_buffer((char *) skb->data, skb->len);
+#endif
+
+	/* check whether WDS is enabled and whether the data frame is a WDS frame=
 */
+
+	if (init_wds) {
+		/* WDS enabled, check for the wds address on the first 6 bytes of the bu=
ffer */
+		src =3D skb->data + 6;
+		memmove(skb->data, src, skb->len - 6);
+		skb_trim(skb, skb->len - 6);
+	}
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	DEBUG(SHOW_TRACING, "Fragment size %i in skb at %p\n", size, skb);
+	DEBUG(SHOW_TRACING, "Skb data at %p, length %i\n", skb->data, skb->len);
+
+	/* display the buffer contents for debugging */
+	DEBUG(SHOW_BUFFER_CONTENTS, "\nrx %p ", skb->data);
+	display_buffer((char *) skb->data, skb->len);
+#endif
+
+	/* do some additional sk_buff and network layer parameters */
+	skb->dev =3D ndev;
+
+	/* take care of monitor mode and spy monitoring. */
+	if (unlikely(priv->iw_mode =3D=3D IW_MODE_MONITOR))
+		discard =3D islpci_monitor_rx(priv, &skb);
+	else {
+		if (unlikely(skb->data[2 * ETH_ALEN] =3D=3D 0)) {
+			/* The packet has a rx_annex. Read it for spy monitoring, Then
+			 * remove it, while keeping the 2 leading MAC addr.
+			 */
+			struct iw_quality wstats;
+			struct rx_annex_header *annex =3D
+			    (struct rx_annex_header *) skb->data;
+			wstats.level =3D annex->rfmon.rssi;
+			/* The noise value can be a bit outdated if nobody's=20
+			 * reading wireless stats... */
+			wstats.noise =3D priv->local_iwstatistics.qual.noise;
+			wstats.qual =3D wstats.level - wstats.noise;
+			wstats.updated =3D 0x07;
+			/* Update spy records */
+			wireless_spy_update(ndev, annex->addr2, &wstats);
+
+			memcpy(skb->data + sizeof (struct rfmon_header),
+			       skb->data, 2 * ETH_ALEN);
+			skb_pull(skb, sizeof (struct rfmon_header));
+		}
+		skb->protocol =3D eth_type_trans(skb, ndev);
+	}
+	skb->ip_summed =3D CHECKSUM_NONE;
+	priv->statistics.rx_packets++;
+	priv->statistics.rx_bytes +=3D size;
+
+	/* deliver the skb to the network layer */
+#ifdef ISLPCI_ETH_DEBUG
+	printk
+	    ("islpci_eth_receive:netif_rx %2.2X %2.2X %2.2X %2.2X %2.2X %2.2X\n",
+	     skb->data[0], skb->data[1], skb->data[2], skb->data[3],
+	     skb->data[4], skb->data[5]);
+#endif
+	if (unlikely(discard)) {
+		dev_kfree_skb_irq(skb);
+		skb =3D NULL;
+	} else
+		netif_rx(skb);
+
+	/* increment the read index for the rx data low queue */
+	priv->free_data_rx++;
+
+	/* add one or more sk_buff structures */
+	while (index =3D
+	       le32_to_cpu(control_block->
+			   driver_curr_frag[ISL38XX_CB_RX_DATA_LQ]),
+	       index - priv->free_data_rx < ISL38XX_CB_RX_QSIZE) {
+		/* allocate an sk_buff for received data frames storage
+		 * include any required allignment operations */
+		skb =3D dev_alloc_skb(MAX_FRAGMENT_SIZE_RX + 2);
+		if (unlikely(skb =3D=3D NULL)) {
+			/* error allocating an sk_buff structure elements */
+			DEBUG(SHOW_ERROR_MESSAGES, "Error allocating skb \n");
+			break;
+		}
+		skb_reserve(skb, (4 - (long) skb->data) & 0x03);
+		/* store the new skb structure pointer */
+		index =3D index % ISL38XX_CB_RX_QSIZE;
+		priv->data_low_rx[index] =3D skb;
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+		DEBUG(SHOW_TRACING,
+		      "new alloc skb %p skb->data %p skb->len %u index %u truesize %u\n =
",
+		      skb, skb->data, skb->len, index, skb->truesize);
+#endif
+
+		/* set the streaming DMA mapping for proper PCI bus operation */
+		priv->pci_map_rx_address[index] =3D
+		    pci_map_single(priv->pdev, (void *) skb->data,
+				   MAX_FRAGMENT_SIZE_RX + 2,
+				   PCI_DMA_FROMDEVICE);
+		if (unlikely(priv->pci_map_rx_address[index] =3D=3D (dma_addr_t) NULL)) {
+			/* error mapping the buffer to device accessable memory address */
+			DEBUG(SHOW_ERROR_MESSAGES,
+			      "Error mapping DMA address\n");
+
+			/* free the skbuf structure before aborting */
+			dev_kfree_skb_irq((struct sk_buff *) skb);
+			skb =3D NULL;
+			break;
+		}
+		/* update the fragment address */
+		control_block->rx_data_low[index].address =3D cpu_to_le32((u32)
+									priv->
+									pci_map_rx_address
+									[index]);
+		wmb();
+
+		/* increment the driver read pointer */
+		add_le32p((u32 *) &control_block->
+			  driver_curr_frag[ISL38XX_CB_RX_DATA_LQ], 1);
+	}
+
+	/* trigger the device */
+	islpci_trigger(priv);
+
+	return 0;
+}
+
+void
+islpci_do_reset_and_wake(void *data)
+{
+	islpci_private *priv =3D (islpci_private *) data;
+	islpci_reset(priv, 1);
+	netif_wake_queue(priv->ndev);
+	priv->reset_task_pending =3D 0;
+}
+
+void
+islpci_eth_tx_timeout(struct net_device *ndev)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	struct net_device_stats *statistics =3D &priv->statistics;
+
+	/* increment the transmit error counter */
+	statistics->tx_errors++;
+
+	if (!priv->reset_task_pending) {
+		priv->reset_task_pending =3D 1;
+		netif_stop_queue(ndev);
+		schedule_work(&priv->reset_task);
+	}
+
+	return;
+}
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/p=
rism54/islpci_eth.h linux-2.4.26-prism54/drivers/net/wireless/prism54/islpc=
i_eth.h
--- linux-2.4.26/drivers/net/wireless/prism54/islpci_eth.h	1970-01-01 00:00=
:00.000000000 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/prism54/islpci_eth.h	2004-07-=
21 09:00:04.000000000 +0000
@@ -0,0 +1,73 @@
+/*
+ * =20
+ *  Copyright (C) 2002 Intersil Americas Inc.
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ */
+
+#ifndef _ISLPCI_ETH_H
+#define _ISLPCI_ETH_H
+
+#include "isl_38xx.h"
+#include "islpci_dev.h"
+
+struct rfmon_header {
+	u16 unk0;		/* =3D 0x0000 */
+	u16 length;		/* =3D 0x1400 */
+	u32 clock;		/* 1MHz clock */
+	u8 flags;
+	u8 unk1;
+	u8 rate;
+	u8 unk2;
+	u16 freq;
+	u16 unk3;
+	u8 rssi;
+	u8 padding[3];
+} __attribute__ ((packed));
+
+struct rx_annex_header {
+	u8 addr1[ETH_ALEN];
+	u8 addr2[ETH_ALEN];
+	struct rfmon_header rfmon;
+} __attribute__ ((packed));
+
+/* wlan-ng (and hopefully others) AVS header, version one.  Fields in
+ * network byte order. */
+#define P80211CAPTURE_VERSION 0x80211001
+
+struct avs_80211_1_header {
+	uint32_t version;
+	uint32_t length;
+	uint64_t mactime;
+	uint64_t hosttime;
+	uint32_t phytype;
+	uint32_t channel;
+	uint32_t datarate;
+	uint32_t antenna;
+	uint32_t priority;
+	uint32_t ssi_type;
+	int32_t ssi_signal;
+	int32_t ssi_noise;
+	uint32_t preamble;
+	uint32_t encoding;
+};
+
+void islpci_eth_cleanup_transmit(islpci_private *, isl38xx_control_block *=
);
+int islpci_eth_transmit(struct sk_buff *, struct net_device *);
+int islpci_eth_receive(islpci_private *);
+void islpci_eth_tx_timeout(struct net_device *);
+void islpci_do_reset_and_wake(void *data);
+
+#endif				/* _ISL_GEN_H */
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/p=
rism54/islpci_hotplug.c linux-2.4.26-prism54/drivers/net/wireless/prism54/i=
slpci_hotplug.c
--- linux-2.4.26/drivers/net/wireless/prism54/islpci_hotplug.c	1970-01-01 0=
0:00:00.000000000 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/prism54/islpci_hotplug.c	2004=
-07-21 09:00:04.000000000 +0000
@@ -0,0 +1,494 @@
+/*
+ * =20
+ *  Copyright (C) 2002 Intersil Americas Inc.
+ *  Copyright (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ */
+
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/delay.h>
+#include <linux/init.h> /* For __init, __exit */
+
+#include "prismcompat.h"
+#include "islpci_dev.h"
+#include "islpci_mgt.h"		/* for pc_debug */
+#include "isl_oid.h"
+
+#define DRV_NAME	"prism54"
+#define DRV_VERSION	"1.2"
+
+MODULE_AUTHOR("[Intersil] R.Bastings and W.Termorshuizen, The prism54.org =
Development Team <prism54-devel@prism54.org>");
+MODULE_DESCRIPTION("The Prism54 802.11 Wireless LAN adapter");
+MODULE_LICENSE("GPL");
+
+static int	init_pcitm =3D 0;
+module_param(init_pcitm, int, 0);
+
+/* In this order: vendor, device, subvendor, subdevice, class, class_mask,
+ * driver_data=20
+ * If you have an update for this please contact prism54-devel@prism54.org=
=20
+ * The latest list can be found at http://prism54.org/supported_cards.php =
*/
+static const struct pci_device_id prism54_id_tbl[] =3D {
+	/* 3COM 3CRWE154G72 Wireless LAN adapter */
+	{
+	 PCIVENDOR_3COM, PCIDEVICE_3COM6001,
+	 PCIVENDOR_3COM, PCIDEVICE_3COM6001,
+	 0, 0, 0
+	},
+
+	/* D-Link Air Plus Xtreme G A1 - DWL-g650 A1 */
+	{
+	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
+	 PCIVENDOR_DLINK, 0x3202UL,=20
+	 0, 0, 0
+	},
+
+	/* I-O Data WN-G54/CB - WN-G54/CB */
+	{
+	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
+	 PCIVENDOR_IODATA, 0xd019UL,=20
+	 0, 0, 0
+	},
+
+	/* Netgear WG511 */
+	{
+	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
+	 PCIVENDOR_NETGEAR, 0x4800UL,
+	 0, 0, 0
+	},
+
+	/* Tekram Technology clones, Allnet, Netcomm, Zyxel */
+	{
+	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
+	 PCIVENDOR_TTL, 0x1605UL,
+	 0, 0, 0
+	},
+
+	/* SMC2802W */
+	{
+	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
+	 PCIVENDOR_SMC, 0x2802UL,
+	 0, 0, 0
+	},
+
+	/* SMC2835W */
+	{
+	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
+	 PCIVENDOR_SMC, 0x2835UL,
+	 0, 0, 0
+	},
+
+	/* Corega CG-WLCB54GT */
+	{
+	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
+	 PCIVENDOR_ATI, 0xc104UL,
+	 0, 0, 0
+	},
+
+	/* I4 Z-Com XG-600 */
+	{
+	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
+	 PCIVENDOR_I4, 0x0014UL,
+	 0, 0, 0
+	},
+
+	/* I4 Z-Com XG-900  and clones Macer, Ovislink, Planex, Peabird, */
+	/* Sitecom, Xterasys */
+	{
+	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
+	 PCIVENDOR_I4, 0x0020UL,
+	 0, 0, 0
+	},
+
+	/* SMC 2802W V2 */
+	{
+	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
+	 PCIVENDOR_ACCTON, 0xee03UL,
+	 0, 0, 0
+	},
+
+	/* SMC 2835W V2 */
+	{
+	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
+	 PCIVENDOR_SMC, 0xa835UL,
+	 0, 0, 0
+	},
+
+	/* Intersil PRISM Indigo Wireless LAN adapter */
+	{
+	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3877,
+	 PCI_ANY_ID, PCI_ANY_ID,
+	 0, 0, 0
+	},
+
+	/* Intersil PRISM Duette/Prism GT Wireless LAN adapter */
+	/* Default */
+	{
+	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
+	 PCI_ANY_ID, PCI_ANY_ID,
+	 0, 0, 0
+	},
+
+	/* End of list */
+	{0,0,0,0,0,0,0}
+};
+
+/* register the device with the Hotplug facilities of the kernel */
+MODULE_DEVICE_TABLE(pci, prism54_id_tbl);
+
+static int prism54_probe(struct pci_dev *, const struct pci_device_id *);
+static void prism54_remove(struct pci_dev *);
+static int prism54_suspend(struct pci_dev *, u32 state);
+static int prism54_resume(struct pci_dev *);
+
+static struct pci_driver prism54_driver =3D {
+	.name =3D DRV_NAME,
+	.id_table =3D prism54_id_tbl,
+	.probe =3D prism54_probe,
+	.remove =3D prism54_remove,
+	.suspend =3D prism54_suspend,
+	.resume =3D prism54_resume,
+	/* .enable_wake ; we don't support this yet */
+};
+
+static void
+prism54_get_card_model(struct net_device *ndev)
+{
+	islpci_private	*priv;
+	char		*modelp;
+	int		notwork =3D 0;
+
+	priv =3D netdev_priv(ndev);
+	switch (priv->pdev->subsystem_device) {
+	case PCIDEVICE_ISL3877:
+		modelp =3D "PRISM Indigo";
+		break;
+	case PCIDEVICE_ISL3886:
+		modelp =3D "PRISM Javelin / Xbow";
+		break;
+	case PCIDEVICE_3COM6001:
+		modelp =3D "3COM 3CRWE154G72";
+		break;
+	case 0x3202UL:
+		modelp =3D "D-Link DWL-g650 A1";
+		break;
+	case 0xd019UL:
+		modelp =3D "WN-G54/CB";
+		break;
+	case 0x4800UL:
+		modelp =3D "Netgear WG511";
+		break;
+	case 0x2802UL:
+		modelp =3D "SMC2802W";
+		break;
+	case 0xee03UL:
+		modelp =3D "SMC2802W V2";
+		notwork =3D 1;
+		break;
+	case 0x2835UL:
+		modelp =3D "SMC2835W";
+		break;
+	case 0xa835UL:
+		modelp =3D "SMC2835W V2";
+		notwork =3D 1;
+		break;
+	case 0xc104UL:
+		modelp =3D "CG-WLCB54GT";
+		break;
+	case 0x1605UL:
+		modelp =3D "Tekram Technology clone";
+		break;
+	/* Let's leave this one out for now since it seems bogus/wrong=20
+	 * Even if the manufacturer did use 0x0000UL it may not be correct
+	 * by their part, therefore deserving no name ;) */
+	/*      case 0x0000UL:=20
+	 *              modelp =3D "SparkLAN WL-850F";
+	 *              break;*/
+
+	/* We have two reported for the one below :( */
+	case 0x0014UL:
+		modelp =3D "I4 Z-Com XG-600 and clones";
+		break;
+	case 0x0020UL:
+		modelp =3D "I4 Z-Com XG-900 and clones";
+		break;
+/* Default it */
+/*
+	case PCIDEVICE_ISL3890:
+		modelp =3D "PRISM Duette/GT";
+		break;
+*/
+	default:
+		modelp =3D "PRISM Duette/GT";
+	}
+	printk(KERN_DEBUG "%s: %s driver detected card model: %s\n",
+			ndev->name, DRV_NAME, modelp);
+	if ( notwork ) {
+		printk(KERN_DEBUG "%s: %s Warning - This may not work\n",
+			ndev->name, DRV_NAME);
+	}
+	return;
+}
+
+/*************************************************************************=
*****
+    Module initialization functions
+**************************************************************************=
****/
+
+int
+prism54_probe(struct pci_dev *pdev, const struct pci_device_id *id)
+{
+	struct net_device *ndev;
+	u8 latency_tmr;
+	u32 mem_addr;
+	islpci_private *priv;
+	int rvalue;
+
+	/* TRACE(DRV_NAME); */
+=09
+=09
+	/* Enable the pci device */
+	if (pci_enable_device(pdev)) {
+		printk(KERN_ERR "%s: pci_enable_device() failed.\n", DRV_NAME);
+		return -ENODEV;
+	}
+
+	/* check whether the latency timer is set correctly */
+	pci_read_config_byte(pdev, PCI_LATENCY_TIMER, &latency_tmr);
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	DEBUG(SHOW_TRACING, "latency timer: %x\n", latency_tmr);
+#endif
+	if (latency_tmr < PCIDEVICE_LATENCY_TIMER_MIN) {
+		/* set the latency timer */
+		pci_write_config_byte(pdev, PCI_LATENCY_TIMER,
+				      PCIDEVICE_LATENCY_TIMER_VAL);
+	}
+
+	/* enable PCI DMA */
+	if (pci_set_dma_mask(pdev, 0xffffffff)) {
+		printk(KERN_ERR "%s: 32-bit PCI DMA not supported", DRV_NAME);
+		goto do_pci_disable_device;
+        }
+
+	/* 0x40 is the programmable timer to configure the response timeout (TRDY=
_TIMEOUT)
+	 * 0x41 is the programmable timer to configure the retry timeout (RETRY_T=
IMEOUT)
+	 * 	The RETRY_TIMEOUT is used to set the number of retries that the core,=
 as a
+	 * 	Master, will perform before abandoning a cycle. The default value for
+	 * 	RETRY_TIMEOUT is 0x80, which far exceeds the PCI 2.1 requirement for =
new
+	 * 	devices. A write of zero to the RETRY_TIMEOUT register disables this
+	 * 	function to allow use with any non-compliant legacy devices that may
+	 * 	execute more retries.
+	 *
+	 * 	Writing zero to both these two registers will disable both timeouts a=
nd
+	 * 	*can* solve problems caused by devices that are slow to respond.
+	 *	Make this configurable - MSW
+	 */
+	if ( init_pcitm >=3D 0 ) {
+		pci_write_config_byte(pdev, 0x40, (u8)init_pcitm);
+		pci_write_config_byte(pdev, 0x41, (u8)init_pcitm);
+	} else {
+		printk(KERN_INFO "PCI TRDY/RETRY unchanged\n");
+	}
+
+	/* request the pci device I/O regions */
+	rvalue =3D pci_request_regions(pdev, DRV_NAME);
+	if (rvalue) {
+		printk(KERN_ERR "%s: pci_request_regions failure (rc=3D%d)\n",
+		       DRV_NAME, rvalue);
+		goto do_pci_disable_device;
+	}
+
+	/* check if the memory window is indeed set */
+	rvalue =3D pci_read_config_dword(pdev, PCI_BASE_ADDRESS_0, &mem_addr);
+	if (rvalue || !mem_addr) {
+		printk(KERN_ERR "%s: PCI device memory region not configured; fix your B=
IOS or CardBus bridge/drivers\n",
+		       DRV_NAME);
+		goto do_pci_disable_device;
+	}
+
+	/* enable PCI bus-mastering */
+	DEBUG(SHOW_TRACING, "%s: pci_set_master(pdev)\n", DRV_NAME);
+	pci_set_master(pdev);
+
+	/* enable MWI */
+	pci_set_mwi(pdev);
+
+	/* setup the network device interface and its structure */
+	if (!(ndev =3D islpci_setup(pdev))) {
+		/* error configuring the driver as a network device */
+		printk(KERN_ERR "%s: could not configure network device\n",
+		       DRV_NAME);
+		goto do_pci_release_regions;
+	}
+
+	priv =3D netdev_priv(ndev);
+	islpci_set_state(priv, PRV_STATE_PREBOOT); /* we are attempting to boot */
+
+	/* card is in unknown state yet, might have some interrupts pending */
+	isl38xx_disable_interrupts(priv->device_base);
+
+	/* request for the interrupt before uploading the firmware */
+	rvalue =3D request_irq(pdev->irq, &islpci_interrupt,
+			     SA_SHIRQ, ndev->name, priv);
+
+	if (rvalue) {
+		/* error, could not hook the handler to the irq */
+		printk(KERN_ERR "%s: could not install IRQ handler\n",
+		       ndev->name);
+		goto do_unregister_netdev;
+	}
+
+	/* firmware upload is triggered in islpci_open */
+
+	/* Pretty card model discovery output */
+	prism54_get_card_model(ndev);
+
+	return 0;
+
+      do_unregister_netdev:
+	unregister_netdev(ndev);
+	islpci_free_memory(priv);
+	pci_set_drvdata(pdev, 0);
+	free_netdev(ndev);
+	priv =3D 0;
+      do_pci_release_regions:
+	pci_release_regions(pdev);
+      do_pci_disable_device:
+	pci_disable_device(pdev);
+	return -EIO;
+}
+
+/* set by cleanup_module */
+static volatile int __in_cleanup_module =3D 0;
+
+/* this one removes one(!!) instance only */
+void
+prism54_remove(struct pci_dev *pdev)
+{
+	struct net_device *ndev =3D pci_get_drvdata(pdev);
+	islpci_private *priv =3D ndev ? netdev_priv(ndev) : 0;
+	BUG_ON(!priv);
+
+	if (!__in_cleanup_module) {
+		printk(KERN_DEBUG "%s: hot unplug detected\n", ndev->name);
+		islpci_set_state(priv, PRV_STATE_OFF);
+	}
+
+	printk(KERN_DEBUG "%s: removing device\n", ndev->name);
+
+	unregister_netdev(ndev);
+
+	/* free the interrupt request */
+
+	if (islpci_get_state(priv) !=3D PRV_STATE_OFF) {
+		isl38xx_disable_interrupts(priv->device_base);
+		islpci_set_state(priv, PRV_STATE_OFF);
+		/* This bellow causes a lockup at rmmod time. It might be
+		 * because some interrupts still linger after rmmod time,=20
+		 * see bug #17 */
+		/* pci_set_power_state(pdev, 3);*/	/* try to power-off */
+	}
+
+	free_irq(pdev->irq, priv);
+
+	/* free the PCI memory and unmap the remapped page */
+	islpci_free_memory(priv);
+
+	pci_set_drvdata(pdev, 0);
+	free_netdev(ndev);
+	priv =3D 0;
+
+	pci_release_regions(pdev);
+
+	pci_disable_device(pdev);
+}
+
+int
+prism54_suspend(struct pci_dev *pdev, u32 state)
+{
+	struct net_device *ndev =3D pci_get_drvdata(pdev);
+	islpci_private *priv =3D ndev ? netdev_priv(ndev) : 0;
+	BUG_ON(!priv);
+
+	printk(KERN_NOTICE "%s: got suspend request (state %d)\n",
+	       ndev->name, state);
+
+	pci_save_state(pdev, priv->pci_state);
+
+	/* tell the device not to trigger interrupts for now... */
+	isl38xx_disable_interrupts(priv->device_base);
+
+	/* from now on assume the hardware was already powered down
+	   and don't touch it anymore */
+	islpci_set_state(priv, PRV_STATE_OFF);
+
+	netif_stop_queue(ndev);
+	netif_device_detach(ndev);
+
+	return 0;
+}
+
+int
+prism54_resume(struct pci_dev *pdev)
+{
+	struct net_device *ndev =3D pci_get_drvdata(pdev);
+	islpci_private *priv =3D ndev ? netdev_priv(ndev) : 0;
+	BUG_ON(!priv);
+
+	printk(KERN_NOTICE "%s: got resume request\n", ndev->name);
+
+	pci_restore_state(pdev, priv->pci_state);
+
+	/* alright let's go into the PREBOOT state */
+	islpci_reset(priv, 1);
+
+	netif_device_attach(ndev);
+	netif_start_queue(ndev);
+
+	return 0;
+}
+
+static int __init
+prism54_module_init(void)
+{
+	printk(KERN_INFO "Loaded %s driver, version %s\n",
+	       DRV_NAME, DRV_VERSION);
+
+	__bug_on_wrong_struct_sizes ();
+
+	return pci_module_init(&prism54_driver);
+}
+
+/* by the time prism54_module_exit() terminates, as a postcondition
+ * all instances will have been destroyed by calls to
+ * prism54_remove() */
+static void __exit
+prism54_module_exit(void)
+{
+	__in_cleanup_module =3D 1;
+
+	pci_unregister_driver(&prism54_driver);
+
+	printk(KERN_INFO "Unloaded %s driver\n", DRV_NAME);
+
+	__in_cleanup_module =3D 0;
+}
+
+/* register entry points */
+module_init(prism54_module_init);
+module_exit(prism54_module_exit);
+/* EOF */
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/p=
rism54/islpci_mgt.c linux-2.4.26-prism54/drivers/net/wireless/prism54/islpc=
i_mgt.c
--- linux-2.4.26/drivers/net/wireless/prism54/islpci_mgt.c	1970-01-01 00:00=
:00.000000000 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/prism54/islpci_mgt.c	2004-07-=
21 09:00:04.000000000 +0000
@@ -0,0 +1,510 @@
+/*
+ * =20
+ *  Copyright (C) 2002 Intersil Americas Inc.
+ *  Copyright 2004 Jens Maurer <Jens.Maurer@gmx.net>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ */
+
+#include <linux/config.h>
+#include <linux/netdevice.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+
+#include <asm/io.h>
+#include <asm/system.h>
+#include <linux/if_arp.h>
+
+#include "prismcompat.h"
+#include "isl_38xx.h"
+#include "islpci_mgt.h"
+#include "isl_oid.h"		/* additional types and defs for isl38xx fw */
+#include "isl_ioctl.h"
+
+#include <net/iw_handler.h>
+
+/*************************************************************************=
*****
+        Global variable definition section
+**************************************************************************=
****/
+int pc_debug =3D VERBOSE;
+module_param(pc_debug, int, 0);
+
+/*************************************************************************=
*****
+    Driver general functions
+**************************************************************************=
****/
+void
+display_buffer(char *buffer, int length)
+{
+	if ((pc_debug & SHOW_BUFFER_CONTENTS) =3D=3D 0)
+		return;
+
+	while (length > 0) {
+		printk("[%02x]", *buffer & 255);
+		length--;
+		buffer++;
+	}
+
+	printk("\n");
+}
+
+/*************************************************************************=
****
+    Queue handling for management frames
+**************************************************************************=
****/
+
+/*
+ * Helper function to create a PIMFOR management frame header.
+ */
+static void
+pimfor_encode_header(int operation, u32 oid, u32 length, pimfor_header_t *=
h)
+{
+	h->version =3D PIMFOR_VERSION;
+	h->operation =3D operation;
+	h->device_id =3D PIMFOR_DEV_ID_MHLI_MIB;
+	h->flags =3D 0;
+	h->oid =3D cpu_to_be32(oid);
+	h->length =3D cpu_to_be32(length);
+}
+
+/*
+ * Helper function to analyze a PIMFOR management frame header.
+ */
+static pimfor_header_t *
+pimfor_decode_header(void *data, int len)
+{
+	pimfor_header_t *h =3D data;
+
+	while ((void *) h < data + len) {
+		if (h->flags & PIMFOR_FLAG_LITTLE_ENDIAN) {
+			le32_to_cpus(&h->oid);
+			le32_to_cpus(&h->length);
+		} else {
+			be32_to_cpus(&h->oid);
+			be32_to_cpus(&h->length);
+		}
+		if (h->oid !=3D OID_INL_TUNNEL)
+			return h;
+		h++;
+	}
+	return NULL;
+}
+
+/*
+ * Fill the receive queue for management frames with fresh buffers.
+ */
+int
+islpci_mgmt_rx_fill(struct net_device *ndev)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	isl38xx_control_block *cb =3D	/* volatile not needed */
+	    (isl38xx_control_block *) priv->control_block;
+	u32 curr =3D le32_to_cpu(cb->driver_curr_frag[ISL38XX_CB_RX_MGMTQ]);
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	DEBUG(SHOW_FUNCTION_CALLS, "islpci_mgmt_rx_fill \n");
+#endif
+
+	while (curr - priv->index_mgmt_rx < ISL38XX_CB_MGMT_QSIZE) {
+		u32 index =3D curr % ISL38XX_CB_MGMT_QSIZE;
+		struct islpci_membuf *buf =3D &priv->mgmt_rx[index];
+		isl38xx_fragment *frag =3D &cb->rx_data_mgmt[index];
+
+		if (buf->mem =3D=3D NULL) {
+			buf->mem =3D kmalloc(MGMT_FRAME_SIZE, GFP_ATOMIC);
+			if (!buf->mem) {
+				printk(KERN_WARNING
+				       "Error allocating management frame.\n");
+				return -ENOMEM;
+			}
+			buf->size =3D MGMT_FRAME_SIZE;
+		}
+		if (buf->pci_addr =3D=3D 0) {
+			buf->pci_addr =3D pci_map_single(priv->pdev, buf->mem,
+						       MGMT_FRAME_SIZE,
+						       PCI_DMA_FROMDEVICE);
+			if (!buf->pci_addr) {
+				printk(KERN_WARNING
+				       "Failed to make memory DMA'able\n.");
+				return -ENOMEM;
+			}
+		}
+
+		/* be safe: always reset control block information */
+		frag->size =3D cpu_to_le16(MGMT_FRAME_SIZE);
+		frag->flags =3D 0;
+		frag->address =3D cpu_to_le32(buf->pci_addr);
+		curr++;
+
+		/* The fragment address in the control block must have
+		 * been written before announcing the frame buffer to
+		 * device */
+		wmb();
+		cb->driver_curr_frag[ISL38XX_CB_RX_MGMTQ] =3D cpu_to_le32(curr);
+	}
+	return 0;
+}
+
+/*
+ * Create and transmit a management frame using "operation" and "oid",
+ * with arguments data/length.
+ * We either return an error and free the frame, or we return 0 and
+ * islpci_mgt_cleanup_transmit() frees the frame in the tx-done
+ * interrupt.
+ */
+static int
+islpci_mgt_transmit(struct net_device *ndev, int operation, unsigned long =
oid,
+		    void *data, int length)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	isl38xx_control_block *cb =3D
+	    (isl38xx_control_block *) priv->control_block;
+	void *p;
+	int err =3D -EINVAL;
+	unsigned long flags;
+	isl38xx_fragment *frag;
+	struct islpci_membuf buf;
+	u32 curr_frag;
+	int index;
+	int frag_len =3D length + PIMFOR_HEADER_SIZE;
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	DEBUG(SHOW_FUNCTION_CALLS, "islpci_mgt_transmit\n");
+#endif
+
+	if (frag_len > MGMT_FRAME_SIZE) {
+		printk(KERN_DEBUG "%s: mgmt frame too large %d\n",
+		       ndev->name, frag_len);
+		goto error;
+	}
+
+	err =3D -ENOMEM;
+	p =3D buf.mem =3D kmalloc(frag_len, GFP_KERNEL);
+	if (!buf.mem) {
+		printk(KERN_DEBUG "%s: cannot allocate mgmt frame\n",
+		       ndev->name);
+		goto error;
+	}
+	buf.size =3D frag_len;
+
+	/* create the header directly in the fragment data area */
+	pimfor_encode_header(operation, oid, length, (pimfor_header_t *) p);
+	p +=3D PIMFOR_HEADER_SIZE;
+
+	if (data)
+		memcpy(p, data, length);
+	else
+		memset(p, 0, length);
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	{
+		pimfor_header_t *h =3D buf.mem;
+		DEBUG(SHOW_PIMFOR_FRAMES,
+		      "PIMFOR: op %i, oid 0x%08lx, device %i, flags 0x%x length 0x%x \n",
+		      h->operation, oid, h->device_id, h->flags, length);
+
+		/* display the buffer contents for debugging */
+		display_buffer((char *) h, sizeof (pimfor_header_t));
+		display_buffer(p, length);
+	}
+#endif
+
+	err =3D -ENOMEM;
+	buf.pci_addr =3D pci_map_single(priv->pdev, buf.mem, frag_len,
+				      PCI_DMA_TODEVICE);
+	if (!buf.pci_addr) {
+		printk(KERN_WARNING "%s: cannot map PCI memory for mgmt\n",
+		       ndev->name);
+		goto error_free;
+	}
+
+	/* Protect the control block modifications against interrupts. */
+	spin_lock_irqsave(&priv->slock, flags);
+	curr_frag =3D le32_to_cpu(cb->driver_curr_frag[ISL38XX_CB_TX_MGMTQ]);
+	if (curr_frag - priv->index_mgmt_tx >=3D ISL38XX_CB_MGMT_QSIZE) {
+		printk(KERN_WARNING "%s: mgmt tx queue is still full\n",
+		       ndev->name);
+		goto error_unlock;
+	}
+
+	/* commit the frame to the tx device queue */
+	index =3D curr_frag % ISL38XX_CB_MGMT_QSIZE;
+	priv->mgmt_tx[index] =3D buf;
+	frag =3D &cb->tx_data_mgmt[index];
+	frag->size =3D cpu_to_le16(frag_len);
+	frag->flags =3D 0;	/* for any other than the last fragment, set to 1 */
+	frag->address =3D cpu_to_le32(buf.pci_addr);
+
+	/* The fragment address in the control block must have
+	 * been written before announcing the frame buffer to
+	 * device */
+	wmb();
+	cb->driver_curr_frag[ISL38XX_CB_TX_MGMTQ] =3D cpu_to_le32(curr_frag + 1);
+	spin_unlock_irqrestore(&priv->slock, flags);
+
+	/* trigger the device */
+	islpci_trigger(priv);
+	return 0;
+
+      error_unlock:
+	spin_unlock_irqrestore(&priv->slock, flags);
+      error_free:
+	kfree(buf.mem);
+      error:
+	return err;
+}
+
+/*
+ * Receive a management frame from the device.
+ * This can be an arbitrary number of traps, and at most one response
+ * frame for a previous request sent via islpci_mgt_transmit().
+ */
+int
+islpci_mgt_receive(struct net_device *ndev)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	isl38xx_control_block *cb =3D
+	    (isl38xx_control_block *) priv->control_block;
+	u32 curr_frag;
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	DEBUG(SHOW_FUNCTION_CALLS, "islpci_mgt_receive \n");
+#endif
+
+	/* Only once per interrupt, determine fragment range to
+	 * process.  This avoids an endless loop (i.e. lockup) if
+	 * frames come in faster than we can process them. */
+	curr_frag =3D le32_to_cpu(cb->device_curr_frag[ISL38XX_CB_RX_MGMTQ]);
+	barrier();
+
+	for (; priv->index_mgmt_rx < curr_frag; priv->index_mgmt_rx++) {
+		pimfor_header_t *header;
+		u32 index =3D priv->index_mgmt_rx % ISL38XX_CB_MGMT_QSIZE;
+		struct islpci_membuf *buf =3D &priv->mgmt_rx[index];
+		u16 frag_len;
+		int size;
+		struct islpci_mgmtframe *frame;
+
+		/* I have no idea (and no documentation) if flags !=3D 0
+		 * is possible.  Drop the frame, reuse the buffer. */
+		if (le16_to_cpu(cb->rx_data_mgmt[index].flags) !=3D 0) {
+			printk(KERN_WARNING "%s: unknown flags 0x%04x\n",
+			       ndev->name,
+			       le16_to_cpu(cb->rx_data_mgmt[index].flags));
+			continue;
+		}
+
+		/* The device only returns the size of the header(s) here. */
+		frag_len =3D le16_to_cpu(cb->rx_data_mgmt[index].size);
+
+		/*
+		 * We appear to have no way to tell the device the
+		 * size of a receive buffer.  Thus, if this check
+		 * triggers, we likely have kernel heap corruption. */
+		if (frag_len > MGMT_FRAME_SIZE) {
+			printk(KERN_WARNING
+				"%s: Bogus packet size of %d (%#x).\n",
+				ndev->name, frag_len, frag_len);
+			frag_len =3D MGMT_FRAME_SIZE;
+		}
+
+		/* Ensure the results of device DMA are visible to the CPU. */
+		pci_dma_sync_single(priv->pdev, buf->pci_addr,
+				    buf->size, PCI_DMA_FROMDEVICE);
+
+		/* Perform endianess conversion for PIMFOR header in-place. */
+		header =3D pimfor_decode_header(buf->mem, frag_len);
+		if (!header) {
+			printk(KERN_WARNING "%s: no PIMFOR header found\n",
+			       ndev->name);
+			continue;
+		}
+
+		/* The device ID from the PIMFOR packet received from
+		 * the MVC is always 0.  We forward a sensible device_id.
+		 * Not that anyone upstream would care... */
+		header->device_id =3D priv->ndev->ifindex;
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+		DEBUG(SHOW_PIMFOR_FRAMES,
+		      "PIMFOR: op %i, oid 0x%08x, device %i, flags 0x%x length 0x%x \n",
+		      header->operation, header->oid, header->device_id,
+		      header->flags, header->length);
+
+		/* display the buffer contents for debugging */
+		display_buffer((char *) header, PIMFOR_HEADER_SIZE);
+		display_buffer((char *) header + PIMFOR_HEADER_SIZE,
+			       header->length);
+#endif
+
+		/* nobody sends these */
+		if (header->flags & PIMFOR_FLAG_APPLIC_ORIGIN) {
+			printk(KERN_DEBUG
+			       "%s: errant PIMFOR application frame\n",
+			       ndev->name);
+			continue;
+		}
+
+		/* Determine frame size, skipping OID_INL_TUNNEL headers. */
+		size =3D PIMFOR_HEADER_SIZE + header->length;
+		frame =3D kmalloc(sizeof (struct islpci_mgmtframe) + size,
+				GFP_ATOMIC);
+		if (!frame) {
+			printk(KERN_WARNING
+			       "%s: Out of memory, cannot handle oid 0x%08x\n",
+			       ndev->name, header->oid);
+			continue;
+		}
+		frame->ndev =3D ndev;
+		memcpy(&frame->buf, header, size);
+		frame->header =3D (pimfor_header_t *) frame->buf;
+		frame->data =3D frame->buf + PIMFOR_HEADER_SIZE;
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+		DEBUG(SHOW_PIMFOR_FRAMES,
+		      "frame: header: %p, data: %p, size: %d\n",
+		      frame->header, frame->data, size);
+#endif
+
+		if (header->operation =3D=3D PIMFOR_OP_TRAP) {
+#if VERBOSE > SHOW_ERROR_MESSAGES
+			printk(KERN_DEBUG
+			       "TRAP: oid 0x%x, device %i, flags 0x%x length %i\n",
+			       header->oid, header->device_id, header->flags,
+			       header->length);
+#endif
+
+			/* Create work to handle trap out of interrupt
+			 * context. */
+			INIT_WORK(&frame->ws, prism54_process_trap, frame);
+			schedule_work(&frame->ws);
+
+		} else {
+			/* Signal the one waiting process that a response
+			 * has been received. */
+			if ((frame =3D xchg(&priv->mgmt_received, frame)) !=3D NULL) {
+				printk(KERN_WARNING
+				       "%s: mgmt response not collected\n",
+				       ndev->name);
+				kfree(frame);
+			}
+#if VERBOSE > SHOW_ERROR_MESSAGES
+			DEBUG(SHOW_TRACING, "Wake up Mgmt Queue\n");
+#endif
+			wake_up(&priv->mgmt_wqueue);
+		}
+
+	}
+
+	return 0;
+}
+
+/*
+ * Cleanup the transmit queue by freeing all frames handled by the device.
+ */
+void
+islpci_mgt_cleanup_transmit(struct net_device *ndev)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	isl38xx_control_block *cb =3D	/* volatile not needed */
+	    (isl38xx_control_block *) priv->control_block;
+	u32 curr_frag;
+
+#if VERBOSE > SHOW_ERROR_MESSAGES
+	DEBUG(SHOW_FUNCTION_CALLS, "islpci_mgt_cleanup_transmit\n");
+#endif
+
+	/* Only once per cleanup, determine fragment range to
+	 * process.  This avoids an endless loop (i.e. lockup) if
+	 * the device became confused, incrementing device_curr_frag
+	 * rapidly. */
+	curr_frag =3D le32_to_cpu(cb->device_curr_frag[ISL38XX_CB_TX_MGMTQ]);
+	barrier();
+
+	for (; priv->index_mgmt_tx < curr_frag; priv->index_mgmt_tx++) {
+		int index =3D priv->index_mgmt_tx % ISL38XX_CB_MGMT_QSIZE;
+		struct islpci_membuf *buf =3D &priv->mgmt_tx[index];
+		pci_unmap_single(priv->pdev, buf->pci_addr, buf->size,
+				 PCI_DMA_TODEVICE);
+		buf->pci_addr =3D 0;
+		kfree(buf->mem);
+		buf->mem =3D NULL;
+		buf->size =3D 0;
+	}
+}
+
+/*
+ * Perform one request-response transaction to the device.
+ */
+int
+islpci_mgt_transaction(struct net_device *ndev,
+		       int operation, unsigned long oid,
+		       void *senddata, int sendlen,
+		       struct islpci_mgmtframe **recvframe)
+{
+	islpci_private *priv =3D netdev_priv(ndev);
+	const long wait_cycle_jiffies =3D (ISL38XX_WAIT_CYCLE * 10 * HZ) / 1000;
+	long timeout_left =3D ISL38XX_MAX_WAIT_CYCLES * wait_cycle_jiffies;
+	int err;
+	DEFINE_WAIT(wait);
+
+	*recvframe =3D NULL;
+
+	if (down_interruptible(&priv->mgmt_sem))
+		return -ERESTARTSYS;
+
+	prepare_to_wait(&priv->mgmt_wqueue, &wait, TASK_UNINTERRUPTIBLE);
+	err =3D islpci_mgt_transmit(ndev, operation, oid, senddata, sendlen);
+	if (err)
+		goto out;
+
+	err =3D -ETIMEDOUT;
+	while (timeout_left > 0) {
+		int timeleft;
+		struct islpci_mgmtframe *frame;
+
+		timeleft =3D schedule_timeout(wait_cycle_jiffies);
+		frame =3D xchg(&priv->mgmt_received, NULL);
+		if (frame) {
+			if (frame->header->oid =3D=3D oid) {
+				*recvframe =3D frame;
+				err =3D 0;
+				goto out;
+			} else {
+				printk(KERN_DEBUG
+				       "%s: expecting oid 0x%x, received 0x%x.\n",
+				       ndev->name, (unsigned int) oid,
+				       frame->header->oid);
+				kfree(frame);
+				frame =3D NULL;
+			}
+		}
+		if (timeleft =3D=3D 0) {
+			printk(KERN_DEBUG
+				"%s: timeout waiting for mgmt response %lu, "
+				"triggering device\n",
+				ndev->name, timeout_left);
+			islpci_trigger(priv);
+		}
+		timeout_left +=3D timeleft - wait_cycle_jiffies;
+	}
+	printk(KERN_WARNING "%s: timeout waiting for mgmt response\n",
+	       ndev->name);
+
+	/* TODO: we should reset the device here */    =20
+ out:
+	finish_wait(&priv->mgmt_wqueue, &wait);
+	up(&priv->mgmt_sem);
+	return err;
+}
+
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/p=
rism54/islpci_mgt.h linux-2.4.26-prism54/drivers/net/wireless/prism54/islpc=
i_mgt.h
--- linux-2.4.26/drivers/net/wireless/prism54/islpci_mgt.h	1970-01-01 00:00=
:00.000000000 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/prism54/islpci_mgt.h	2004-07-=
21 09:00:04.000000000 +0000
@@ -0,0 +1,162 @@
+/*
+ * =20
+ *  Copyright (C) 2002 Intersil Americas Inc.
+ *  Copyright (C) 2003 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ */
+
+#ifndef _ISLPCI_MGT_H
+#define _ISLPCI_MGT_H
+
+#include <linux/wireless.h>
+#include <linux/skbuff.h>
+
+/*
+ *  Function definitions
+ */
+
+#define K_DEBUG(f, m, args...) do { if(f & m) printk(KERN_DEBUG args); } w=
hile(0)
+#define DEBUG(f, args...) K_DEBUG(f, pc_debug, args)
+
+#define TRACE(devname)   K_DEBUG(SHOW_TRACING, VERBOSE, "%s:  -> " __FUNCT=
ION__ "()\n", devname)
+
+extern int pc_debug;
+#define init_wds 0	/* help compiler optimize away dead code */
+
+
+/* General driver definitions */
+#define PCIVENDOR_INTERSIL                      0x1260UL
+#define PCIVENDOR_3COM				0x10b7UL
+#define PCIVENDOR_DLINK				0x1186UL
+#define PCIVENDOR_I4				0x17cfUL
+#define PCIVENDOR_IODATA			0x10fcUL
+#define PCIVENDOR_NETGEAR			0x1385UL
+#define PCIVENDOR_SMC				0x10b8UL
+#define PCIVENDOR_ACCTON			0x1113UL
+#define PCIVENDOR_ATI				0x1259UL
+#define PCIVENDOR_TTL				0x16a5UL
+
+#define PCIDEVICE_ISL3877                       0x3877UL
+#define PCIDEVICE_ISL3886                       0x3886UL
+#define PCIDEVICE_ISL3890                       0x3890UL
+#define	PCIDEVICE_3COM6001			0x6001UL
+#define PCIDEVICE_LATENCY_TIMER_MIN 		0x40
+#define PCIDEVICE_LATENCY_TIMER_VAL 		0x50
+
+/* Debugging verbose definitions */
+#define SHOW_NOTHING                            0x00	/* overrules everythi=
ng */
+#define SHOW_ANYTHING                           0xFF
+#define SHOW_ERROR_MESSAGES                     0x01
+#define SHOW_TRAPS                              0x02
+#define SHOW_FUNCTION_CALLS                     0x04
+#define SHOW_TRACING                            0x08
+#define SHOW_QUEUE_INDEXES                      0x10
+#define SHOW_PIMFOR_FRAMES                      0x20
+#define SHOW_BUFFER_CONTENTS                    0x40
+#define VERBOSE                                 0x01
+
+/* Default card definitions */
+#define CARD_DEFAULT_CHANNEL                    6
+#define CARD_DEFAULT_MODE                       INL_MODE_CLIENT
+#define CARD_DEFAULT_IW_MODE			IW_MODE_INFRA
+#define CARD_DEFAULT_BSSTYPE                    DOT11_BSSTYPE_INFRA
+#define CARD_DEFAULT_CLIENT_SSID		""
+#define CARD_DEFAULT_AP_SSID			"default"
+#define CARD_DEFAULT_KEY1                       "default_key_1"
+#define CARD_DEFAULT_KEY2                       "default_key_2"
+#define CARD_DEFAULT_KEY3                       "default_key_3"
+#define CARD_DEFAULT_KEY4                       "default_key_4"
+#define CARD_DEFAULT_WEP                        0
+#define CARD_DEFAULT_FILTER                     0
+#define CARD_DEFAULT_WDS                        0
+#define	CARD_DEFAULT_AUTHEN                     DOT11_AUTH_OS
+#define	CARD_DEFAULT_DOT1X			0
+#define CARD_DEFAULT_MLME_MODE			DOT11_MLME_AUTO
+#define CARD_DEFAULT_CONFORMANCE                OID_INL_CONFORMANCE_NONE
+#define CARD_DEFAULT_PROFILE			DOT11_PROFILE_MIXED_G_WIFI
+#define CARD_DEFAULT_MAXFRAMEBURST		DOT11_MAXFRAMEBURST_MIXED_SAFE
+
+/* PIMFOR package definitions */
+#define PIMFOR_ETHERTYPE                        0x8828
+#define PIMFOR_HEADER_SIZE                      12
+#define PIMFOR_VERSION                          1
+#define PIMFOR_OP_GET                           0
+#define PIMFOR_OP_SET                           1
+#define PIMFOR_OP_RESPONSE                      2
+#define PIMFOR_OP_ERROR                         3
+#define PIMFOR_OP_TRAP                          4
+#define PIMFOR_OP_RESERVED                      5	/* till 255 */
+#define PIMFOR_DEV_ID_MHLI_MIB                  0
+#define PIMFOR_FLAG_APPLIC_ORIGIN               0x01
+#define PIMFOR_FLAG_LITTLE_ENDIAN               0x02
+
+static inline void
+add_le32p(u32 * le_number, u32 add)
+{
+	*le_number =3D cpu_to_le32(le32_to_cpup(le_number) + add);
+}
+
+void display_buffer(char *, int);
+
+/*
+ *  Type definition section
+ *
+ *  the structure defines only the header allowing copyless
+ *  frame handling
+ */
+typedef struct {
+	u8 version;
+	u8 operation;
+	u32 oid;
+	u8 device_id;
+	u8 flags;
+	u32 length;
+} __attribute__ ((packed))
+pimfor_header_t;
+
+/* A received and interrupt-processed management frame, either for
+ * schedule_work(prism54_process_trap) or for priv->mgmt_received,
+ * processed by islpci_mgt_transaction(). */
+struct islpci_mgmtframe {
+	struct net_device *ndev;      /* pointer to network device */
+	pimfor_header_t *header;      /* payload header, points into buf */
+	void *data;		      /* payload ex header, points into buf */
+        struct work_struct ws;	      /* argument for schedule_work() */
+	char buf[0];		      /* fragment buffer */
+};
+
+int
+islpci_mgt_receive(struct net_device *ndev);
+
+int
+islpci_mgmt_rx_fill(struct net_device *ndev);
+
+void
+islpci_mgt_cleanup_transmit(struct net_device *ndev);
+
+int
+islpci_mgt_transaction(struct net_device *ndev,
+                       int operation, unsigned long oid,
+		       void *senddata, int sendlen,
+		       struct islpci_mgmtframe **recvframe);
+
+static inline void
+islpci_mgt_release(struct islpci_mgmtframe *frame)
+{
+        kfree(frame);
+}
+
+#endif				/* _ISLPCI_MGT_H */
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/p=
rism54/oid_mgt.c linux-2.4.26-prism54/drivers/net/wireless/prism54/oid_mgt.c
--- linux-2.4.26/drivers/net/wireless/prism54/oid_mgt.c	1970-01-01 00:00:00=
.000000000 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/prism54/oid_mgt.c	2004-07-21 =
09:00:04.000000000 +0000
@@ -0,0 +1,807 @@
+/*  =20
+ *  Copyright (C) 2003,2004 Aurelien Alleaume <slts@free.fr>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ */
+
+#include "prismcompat.h"
+#include "islpci_dev.h"
+#include "islpci_mgt.h"
+#include "isl_oid.h"
+#include "oid_mgt.h"
+#include "isl_ioctl.h"
+
+/* to convert between channel and freq */
+const int frequency_list_bg[] =3D { 2412, 2417, 2422, 2427, 2432, 2437, 24=
42,
+	2447, 2452, 2457, 2462, 2467, 2472, 2484
+};
+
+int
+channel_of_freq(int f)
+{
+	int c =3D 0;
+
+	if ((f >=3D 2412) && (f <=3D 2484)) {
+		while ((c < 14) && (f !=3D frequency_list_bg[c]))
+			c++;
+		return (c >=3D 14) ? 0 : ++c;
+	} else if ((f >=3D (int) 5000) && (f <=3D (int) 6000)) {
+		return ( (f - 5000) / 5 );
+	} else
+		return 0;
+}
+
+#define OID_STRUCT(name,oid,s,t) [name] =3D {oid, 0, sizeof(s), t}
+#define OID_STRUCT_C(name,oid,s,t) OID_STRUCT(name,oid,s,t | OID_FLAG_CACH=
ED)
+#define OID_U32(name,oid) OID_STRUCT(name,oid,u32,OID_TYPE_U32)
+#define OID_U32_C(name,oid) OID_STRUCT_C(name,oid,u32,OID_TYPE_U32)
+#define OID_STRUCT_MLME(name,oid) OID_STRUCT(name,oid,struct obj_mlme,OID_=
TYPE_MLME)
+#define OID_STRUCT_MLMEEX(name,oid) OID_STRUCT(name,oid,struct obj_mlmeex,=
OID_TYPE_MLMEEX)
+
+#define OID_UNKNOWN(name,oid) OID_STRUCT(name,oid,0,0)
+
+struct oid_t isl_oid[] =3D {
+	OID_STRUCT(GEN_OID_MACADDRESS, 0x00000000, u8[6], OID_TYPE_ADDR),
+	OID_U32(GEN_OID_LINKSTATE, 0x00000001),
+	OID_UNKNOWN(GEN_OID_WATCHDOG, 0x00000002),
+	OID_UNKNOWN(GEN_OID_MIBOP, 0x00000003),
+	OID_UNKNOWN(GEN_OID_OPTIONS, 0x00000004),
+	OID_UNKNOWN(GEN_OID_LEDCONFIG, 0x00000005),
+
+	/* 802.11 */
+	OID_U32_C(DOT11_OID_BSSTYPE, 0x10000000),
+	OID_STRUCT_C(DOT11_OID_BSSID, 0x10000001, u8[6], OID_TYPE_RAW),
+	OID_STRUCT_C(DOT11_OID_SSID, 0x10000002, struct obj_ssid,
+		     OID_TYPE_SSID),
+	OID_U32(DOT11_OID_STATE, 0x10000003),
+	OID_U32(DOT11_OID_AID, 0x10000004),
+	OID_STRUCT(DOT11_OID_COUNTRYSTRING, 0x10000005, u8[4], OID_TYPE_RAW),
+	OID_STRUCT_C(DOT11_OID_SSIDOVERRIDE, 0x10000006, struct obj_ssid,
+		     OID_TYPE_SSID),
+
+	OID_U32(DOT11_OID_MEDIUMLIMIT, 0x11000000),
+	OID_U32_C(DOT11_OID_BEACONPERIOD, 0x11000001),
+	OID_U32(DOT11_OID_DTIMPERIOD, 0x11000002),
+	OID_U32(DOT11_OID_ATIMWINDOW, 0x11000003),
+	OID_U32(DOT11_OID_LISTENINTERVAL, 0x11000004),
+	OID_U32(DOT11_OID_CFPPERIOD, 0x11000005),
+	OID_U32(DOT11_OID_CFPDURATION, 0x11000006),
+
+	OID_U32_C(DOT11_OID_AUTHENABLE, 0x12000000),
+	OID_U32_C(DOT11_OID_PRIVACYINVOKED, 0x12000001),
+	OID_U32_C(DOT11_OID_EXUNENCRYPTED, 0x12000002),
+	OID_U32_C(DOT11_OID_DEFKEYID, 0x12000003),
+	[DOT11_OID_DEFKEYX] =3D {0x12000004, 3, sizeof (struct obj_key),
+			       OID_FLAG_CACHED | OID_TYPE_KEY},	/* DOT11_OID_DEFKEY1,...DOT11_O=
ID_DEFKEY4 */
+	OID_UNKNOWN(DOT11_OID_STAKEY, 0x12000008),
+	OID_U32(DOT11_OID_REKEYTHRESHOLD, 0x12000009),
+	OID_UNKNOWN(DOT11_OID_STASC, 0x1200000a),
+
+	OID_U32(DOT11_OID_PRIVTXREJECTED, 0x1a000000),
+	OID_U32(DOT11_OID_PRIVRXPLAIN, 0x1a000001),
+	OID_U32(DOT11_OID_PRIVRXFAILED, 0x1a000002),
+	OID_U32(DOT11_OID_PRIVRXNOKEY, 0x1a000003),
+
+	OID_U32_C(DOT11_OID_RTSTHRESH, 0x13000000),
+	OID_U32_C(DOT11_OID_FRAGTHRESH, 0x13000001),
+	OID_U32_C(DOT11_OID_SHORTRETRIES, 0x13000002),
+	OID_U32_C(DOT11_OID_LONGRETRIES, 0x13000003),
+	OID_U32_C(DOT11_OID_MAXTXLIFETIME, 0x13000004),
+	OID_U32(DOT11_OID_MAXRXLIFETIME, 0x13000005),
+	OID_U32(DOT11_OID_AUTHRESPTIMEOUT, 0x13000006),
+	OID_U32(DOT11_OID_ASSOCRESPTIMEOUT, 0x13000007),
+
+	OID_UNKNOWN(DOT11_OID_ALOFT_TABLE, 0x1d000000),
+	OID_UNKNOWN(DOT11_OID_ALOFT_CTRL_TABLE, 0x1d000001),
+	OID_UNKNOWN(DOT11_OID_ALOFT_RETREAT, 0x1d000002),
+	OID_UNKNOWN(DOT11_OID_ALOFT_PROGRESS, 0x1d000003),
+	OID_U32(DOT11_OID_ALOFT_FIXEDRATE, 0x1d000004),
+	OID_UNKNOWN(DOT11_OID_ALOFT_RSSIGRAPH, 0x1d000005),
+	OID_UNKNOWN(DOT11_OID_ALOFT_CONFIG, 0x1d000006),
+
+	[DOT11_OID_VDCFX] =3D {0x1b000000, 7, 0, 0},
+	OID_U32(DOT11_OID_MAXFRAMEBURST, 0x1b000008),
+
+	OID_U32(DOT11_OID_PSM, 0x14000000),
+	OID_U32(DOT11_OID_CAMTIMEOUT, 0x14000001),
+	OID_U32(DOT11_OID_RECEIVEDTIMS, 0x14000002),
+	OID_U32(DOT11_OID_ROAMPREFERENCE, 0x14000003),
+
+	OID_U32(DOT11_OID_BRIDGELOCAL, 0x15000000),
+	OID_U32(DOT11_OID_CLIENTS, 0x15000001),
+	OID_U32(DOT11_OID_CLIENTSASSOCIATED, 0x15000002),
+	[DOT11_OID_CLIENTX] =3D {0x15000003, 2006, 0, 0},	/* DOT11_OID_CLIENTX,..=
.DOT11_OID_CLIENT2007 */
+
+	OID_STRUCT(DOT11_OID_CLIENTFIND, 0x150007DB, u8[6], OID_TYPE_ADDR),
+	OID_STRUCT(DOT11_OID_WDSLINKADD, 0x150007DC, u8[6], OID_TYPE_ADDR),
+	OID_STRUCT(DOT11_OID_WDSLINKREMOVE, 0x150007DD, u8[6], OID_TYPE_ADDR),
+	OID_STRUCT(DOT11_OID_EAPAUTHSTA, 0x150007DE, u8[6], OID_TYPE_ADDR),
+	OID_STRUCT(DOT11_OID_EAPUNAUTHSTA, 0x150007DF, u8[6], OID_TYPE_ADDR),
+	OID_U32_C(DOT11_OID_DOT1XENABLE, 0x150007E0),
+	OID_UNKNOWN(DOT11_OID_MICFAILURE, 0x150007E1),
+	OID_UNKNOWN(DOT11_OID_REKEYINDICATE, 0x150007E2),
+
+	OID_U32(DOT11_OID_MPDUTXSUCCESSFUL, 0x16000000),
+	OID_U32(DOT11_OID_MPDUTXONERETRY, 0x16000001),
+	OID_U32(DOT11_OID_MPDUTXMULTIPLERETRIES, 0x16000002),
+	OID_U32(DOT11_OID_MPDUTXFAILED, 0x16000003),
+	OID_U32(DOT11_OID_MPDURXSUCCESSFUL, 0x16000004),
+	OID_U32(DOT11_OID_MPDURXDUPS, 0x16000005),
+	OID_U32(DOT11_OID_RTSSUCCESSFUL, 0x16000006),
+	OID_U32(DOT11_OID_RTSFAILED, 0x16000007),
+	OID_U32(DOT11_OID_ACKFAILED, 0x16000008),
+	OID_U32(DOT11_OID_FRAMERECEIVES, 0x16000009),
+	OID_U32(DOT11_OID_FRAMEERRORS, 0x1600000A),
+	OID_U32(DOT11_OID_FRAMEABORTS, 0x1600000B),
+	OID_U32(DOT11_OID_FRAMEABORTSPHY, 0x1600000C),
+
+	OID_U32(DOT11_OID_SLOTTIME, 0x17000000),
+	OID_U32(DOT11_OID_CWMIN, 0x17000001),
+	OID_U32(DOT11_OID_CWMAX, 0x17000002),
+	OID_U32(DOT11_OID_ACKWINDOW, 0x17000003),
+	OID_U32(DOT11_OID_ANTENNARX, 0x17000004),
+	OID_U32(DOT11_OID_ANTENNATX, 0x17000005),
+	OID_U32(DOT11_OID_ANTENNADIVERSITY, 0x17000006),
+	OID_U32_C(DOT11_OID_CHANNEL, 0x17000007),
+	OID_U32_C(DOT11_OID_EDTHRESHOLD, 0x17000008),
+	OID_U32(DOT11_OID_PREAMBLESETTINGS, 0x17000009),
+	OID_STRUCT(DOT11_OID_RATES, 0x1700000A, u8[IWMAX_BITRATES + 1],
+		   OID_TYPE_RAW),
+	OID_U32(DOT11_OID_CCAMODESUPPORTED, 0x1700000B),
+	OID_U32(DOT11_OID_CCAMODE, 0x1700000C),
+	OID_UNKNOWN(DOT11_OID_RSSIVECTOR, 0x1700000D),
+	OID_UNKNOWN(DOT11_OID_OUTPUTPOWERTABLE, 0x1700000E),
+	OID_U32(DOT11_OID_OUTPUTPOWER, 0x1700000F),
+	OID_STRUCT(DOT11_OID_SUPPORTEDRATES, 0x17000010,
+		   u8[IWMAX_BITRATES + 1], OID_TYPE_RAW),
+	OID_U32_C(DOT11_OID_FREQUENCY, 0x17000011),
+	[DOT11_OID_SUPPORTEDFREQUENCIES] =3D
+	    {0x17000012, 0, sizeof (struct obj_frequencies)
+	     + sizeof (u16) * IWMAX_FREQ, OID_TYPE_FREQUENCIES},
+
+	OID_U32(DOT11_OID_NOISEFLOOR, 0x17000013),
+	OID_STRUCT(DOT11_OID_FREQUENCYACTIVITY, 0x17000014, u8[IWMAX_FREQ + 1],
+		   OID_TYPE_RAW),
+	OID_UNKNOWN(DOT11_OID_IQCALIBRATIONTABLE, 0x17000015),
+	OID_U32(DOT11_OID_NONERPPROTECTION, 0x17000016),
+	OID_U32(DOT11_OID_SLOTSETTINGS, 0x17000017),
+	OID_U32(DOT11_OID_NONERPTIMEOUT, 0x17000018),
+	OID_U32(DOT11_OID_PROFILES, 0x17000019),
+	OID_STRUCT(DOT11_OID_EXTENDEDRATES, 0x17000020,
+		   u8[IWMAX_BITRATES + 1], OID_TYPE_RAW),
+
+	OID_STRUCT_MLME(DOT11_OID_DEAUTHENTICATE, 0x18000000),
+	OID_STRUCT_MLME(DOT11_OID_AUTHENTICATE, 0x18000001),
+	OID_STRUCT_MLME(DOT11_OID_DISASSOCIATE, 0x18000002),
+	OID_STRUCT_MLME(DOT11_OID_ASSOCIATE, 0x18000003),
+	OID_UNKNOWN(DOT11_OID_SCAN, 0x18000004),
+	OID_STRUCT_MLMEEX(DOT11_OID_BEACON, 0x18000005),
+	OID_STRUCT_MLMEEX(DOT11_OID_PROBE, 0x18000006),
+	OID_STRUCT_MLMEEX(DOT11_OID_DEAUTHENTICATEEX, 0x18000007),
+	OID_STRUCT_MLMEEX(DOT11_OID_AUTHENTICATEEX, 0x18000008),
+	OID_STRUCT_MLMEEX(DOT11_OID_DISASSOCIATEEX, 0x18000009),
+	OID_STRUCT_MLMEEX(DOT11_OID_ASSOCIATEEX, 0x1800000A),
+	OID_STRUCT_MLMEEX(DOT11_OID_REASSOCIATE, 0x1800000B),
+	OID_STRUCT_MLMEEX(DOT11_OID_REASSOCIATEEX, 0x1800000C),
+
+	OID_U32(DOT11_OID_NONERPSTATUS, 0x1E000000),
+
+	OID_U32(DOT11_OID_STATIMEOUT, 0x19000000),
+	OID_U32_C(DOT11_OID_MLMEAUTOLEVEL, 0x19000001),
+	OID_U32(DOT11_OID_BSSTIMEOUT, 0x19000002),
+	OID_UNKNOWN(DOT11_OID_ATTACHMENT, 0x19000003),
+	OID_STRUCT_C(DOT11_OID_PSMBUFFER, 0x19000004, struct obj_buffer,
+		     OID_TYPE_BUFFER),
+
+	OID_U32(DOT11_OID_BSSS, 0x1C000000),
+	[DOT11_OID_BSSX] =3D {0x1C000001, 63, sizeof (struct obj_bss),
+			    OID_TYPE_BSS},	/*DOT11_OID_BSS1,...,DOT11_OID_BSS64 */
+	OID_STRUCT(DOT11_OID_BSSFIND, 0x1C000042, struct obj_bss, OID_TYPE_BSS),
+	[DOT11_OID_BSSLIST] =3D {0x1C000043, 0, sizeof (struct
+						      obj_bsslist) +
+			       sizeof (struct obj_bss[IWMAX_BSS]),
+			       OID_TYPE_BSSLIST},
+
+	OID_UNKNOWN(OID_INL_TUNNEL, 0xFF020000),
+	OID_UNKNOWN(OID_INL_MEMADDR, 0xFF020001),
+	OID_UNKNOWN(OID_INL_MEMORY, 0xFF020002),
+	OID_U32_C(OID_INL_MODE, 0xFF020003),
+	OID_UNKNOWN(OID_INL_COMPONENT_NR, 0xFF020004),
+	OID_UNKNOWN(OID_INL_VERSION, 0xFF020005),
+	OID_UNKNOWN(OID_INL_INTERFACE_ID, 0xFF020006),
+	OID_UNKNOWN(OID_INL_COMPONENT_ID, 0xFF020007),
+	OID_U32_C(OID_INL_CONFIG, 0xFF020008),
+	OID_U32_C(OID_INL_DOT11D_CONFORMANCE, 0xFF02000C),
+	OID_U32(OID_INL_PHYCAPABILITIES, 0xFF02000D),
+	OID_U32_C(OID_INL_OUTPUTPOWER, 0xFF02000F),
+
+};
+
+int
+mgt_init(islpci_private *priv)
+{
+	int i;
+
+	priv->mib =3D kmalloc(OID_NUM_LAST * sizeof (void *), GFP_KERNEL);
+	if (!priv->mib)
+		return -ENOMEM;
+
+	memset(priv->mib, 0, OID_NUM_LAST * sizeof (void *));
+
+	/* Alloc the cache */
+	for (i =3D 0; i < OID_NUM_LAST; i++) {
+		if (isl_oid[i].flags & OID_FLAG_CACHED) {
+			priv->mib[i] =3D kmalloc(isl_oid[i].size *
+					       (isl_oid[i].range + 1),
+					       GFP_KERNEL);
+			if (!priv->mib[i])
+				return -ENOMEM;
+			memset(priv->mib[i], 0,
+			       isl_oid[i].size * (isl_oid[i].range + 1));
+		} else
+			priv->mib[i] =3D NULL;
+	}
+
+	init_rwsem(&priv->mib_sem);
+	prism54_mib_init(priv);
+
+	return 0;
+}
+
+void
+mgt_clean(islpci_private *priv)
+{
+	int i;
+
+	if (!priv->mib)
+		return;
+	for (i =3D 0; i < OID_NUM_LAST; i++)
+		if (priv->mib[i]) {
+			kfree(priv->mib[i]);
+			priv->mib[i] =3D NULL;
+		}
+	kfree(priv->mib);
+	priv->mib =3D NULL;
+}
+
+void
+mgt_le_to_cpu(int type, void *data)
+{
+	switch (type) {
+	case OID_TYPE_U32:
+		*(u32 *) data =3D le32_to_cpu(*(u32 *) data);
+		break;
+	case OID_TYPE_BUFFER:{
+			struct obj_buffer *buff =3D data;
+			buff->size =3D le32_to_cpu(buff->size);
+			buff->addr =3D le32_to_cpu(buff->addr);
+			break;
+		}
+	case OID_TYPE_BSS:{
+			struct obj_bss *bss =3D data;
+			bss->age =3D le16_to_cpu(bss->age);
+			bss->channel =3D le16_to_cpu(bss->channel);
+			bss->capinfo =3D le16_to_cpu(bss->capinfo);
+			bss->rates =3D le16_to_cpu(bss->rates);
+			bss->basic_rates =3D le16_to_cpu(bss->basic_rates);
+			break;
+		}
+	case OID_TYPE_BSSLIST:{
+			struct obj_bsslist *list =3D data;
+			int i;
+			list->nr =3D le32_to_cpu(list->nr);
+			for (i =3D 0; i < list->nr; i++)
+				mgt_le_to_cpu(OID_TYPE_BSS, &list->bsslist[i]);
+			break;
+		}
+	case OID_TYPE_FREQUENCIES:{
+			struct obj_frequencies *freq =3D data;
+			int i;
+			freq->nr =3D le16_to_cpu(freq->nr);
+			for (i =3D 0; i < freq->nr; i++)
+				freq->mhz[i] =3D le16_to_cpu(freq->mhz[i]);
+			break;
+		}
+	case OID_TYPE_MLME:{
+			struct obj_mlme *mlme =3D data;
+			mlme->id =3D le16_to_cpu(mlme->id);
+			mlme->state =3D le16_to_cpu(mlme->state);
+			mlme->code =3D le16_to_cpu(mlme->code);
+			break;
+		}
+	case OID_TYPE_MLMEEX:{
+			struct obj_mlmeex *mlme =3D data;
+			mlme->id =3D le16_to_cpu(mlme->id);
+			mlme->state =3D le16_to_cpu(mlme->state);
+			mlme->code =3D le16_to_cpu(mlme->code);
+			mlme->size =3D le16_to_cpu(mlme->size);
+			break;
+		}
+	case OID_TYPE_SSID:
+	case OID_TYPE_KEY:
+	case OID_TYPE_ADDR:
+	case OID_TYPE_RAW:
+		break;
+	default:
+		BUG();
+	}
+}
+
+static void
+mgt_cpu_to_le(int type, void *data)
+{
+	switch (type) {
+	case OID_TYPE_U32:
+		*(u32 *) data =3D cpu_to_le32(*(u32 *) data);
+		break;
+	case OID_TYPE_BUFFER:{
+			struct obj_buffer *buff =3D data;
+			buff->size =3D cpu_to_le32(buff->size);
+			buff->addr =3D cpu_to_le32(buff->addr);
+			break;
+		}
+	case OID_TYPE_BSS:{
+			struct obj_bss *bss =3D data;
+			bss->age =3D cpu_to_le16(bss->age);
+			bss->channel =3D cpu_to_le16(bss->channel);
+			bss->capinfo =3D cpu_to_le16(bss->capinfo);
+			bss->rates =3D cpu_to_le16(bss->rates);
+			bss->basic_rates =3D cpu_to_le16(bss->basic_rates);
+			break;
+		}
+	case OID_TYPE_BSSLIST:{
+			struct obj_bsslist *list =3D data;
+			int i;
+			list->nr =3D cpu_to_le32(list->nr);
+			for (i =3D 0; i < list->nr; i++)
+				mgt_cpu_to_le(OID_TYPE_BSS, &list->bsslist[i]);
+			break;
+		}
+	case OID_TYPE_FREQUENCIES:{
+			struct obj_frequencies *freq =3D data;
+			int i;
+			freq->nr =3D cpu_to_le16(freq->nr);
+			for (i =3D 0; i < freq->nr; i++)
+				freq->mhz[i] =3D cpu_to_le16(freq->mhz[i]);
+			break;
+		}
+	case OID_TYPE_MLME:{
+			struct obj_mlme *mlme =3D data;
+			mlme->id =3D cpu_to_le16(mlme->id);
+			mlme->state =3D cpu_to_le16(mlme->state);
+			mlme->code =3D cpu_to_le16(mlme->code);
+			break;
+		}
+	case OID_TYPE_MLMEEX:{
+			struct obj_mlmeex *mlme =3D data;
+			mlme->id =3D cpu_to_le16(mlme->id);
+			mlme->state =3D cpu_to_le16(mlme->state);
+			mlme->code =3D cpu_to_le16(mlme->code);
+			mlme->size =3D cpu_to_le16(mlme->size);
+			break;
+		}
+	case OID_TYPE_SSID:
+	case OID_TYPE_KEY:
+	case OID_TYPE_ADDR:
+	case OID_TYPE_RAW:
+		break;
+	default:
+		BUG();
+	}
+}
+
+/* Note : data is modified during this function */
+
+int
+mgt_set_request(islpci_private *priv, enum oid_num_t n, int extra, void *d=
ata)
+{
+	int ret =3D 0;
+	struct islpci_mgmtframe *response =3D NULL;
+	int response_op =3D PIMFOR_OP_ERROR;
+	int dlen;
+	void *cache, *_data =3D data;
+	u32 oid;
+
+	BUG_ON(OID_NUM_LAST <=3D n);
+	BUG_ON(extra > isl_oid[n].range);
+
+	if (!priv->mib)
+		/* memory has been freed */
+		return -1;
+
+	dlen =3D isl_oid[n].size;
+	cache =3D priv->mib[n];
+	cache +=3D (cache ? extra * dlen : 0);
+	oid =3D isl_oid[n].oid + extra;
+
+	if (_data =3D=3D NULL)
+		/* we are requested to re-set a cached value */
+		_data =3D cache;
+	else
+		mgt_cpu_to_le(isl_oid[n].flags & OID_FLAG_TYPE, _data);
+	/* If we are going to write to the cache, we don't want anyone to read
+	 * it -> acquire write lock.
+	 * Else we could acquire a read lock to be sure we don't bother the
+	 * commit process (which takes a write lock). But I'm not sure if it's
+	 * needed.
+	 */
+	if (cache)
+		down_write(&priv->mib_sem);
+
+	if (islpci_get_state(priv) >=3D PRV_STATE_READY) {
+		ret =3D islpci_mgt_transaction(priv->ndev, PIMFOR_OP_SET, oid,
+					     _data, dlen, &response);
+		if (!ret) {
+			response_op =3D response->header->operation;
+			islpci_mgt_release(response);
+		}
+		if (ret || response_op =3D=3D PIMFOR_OP_ERROR)
+			ret =3D -EIO;
+	} else if (!cache)
+		ret =3D -EIO;
+
+	if (cache) {
+		if (!ret && data)
+			memcpy(cache, _data, dlen);
+		up_write(&priv->mib_sem);
+	}
+
+	/* re-set given data to what it was */
+	if (data)
+		mgt_le_to_cpu(isl_oid[n].flags & OID_FLAG_TYPE, data);
+
+	return ret;
+}
+
+int
+mgt_get_request(islpci_private *priv, enum oid_num_t n, int extra, void *d=
ata,
+		union oid_res_t *res)
+{
+
+	int ret =3D -EIO;
+	int reslen =3D 0;
+	struct islpci_mgmtframe *response =3D NULL;
+
+	int dlen;
+	void *cache, *_res =3D NULL;
+	u32 oid;
+
+	BUG_ON(OID_NUM_LAST <=3D n);
+	BUG_ON(extra > isl_oid[n].range);
+
+	if (!priv->mib)
+		/* memory has been freed */
+		return -1;
+
+	dlen =3D isl_oid[n].size;
+	cache =3D priv->mib[n];
+	cache +=3D cache ? extra * dlen : 0;
+	oid =3D isl_oid[n].oid + extra;
+	reslen =3D dlen;
+
+	if (cache)
+		down_read(&priv->mib_sem);
+
+	if (islpci_get_state(priv) >=3D PRV_STATE_READY) {
+		ret =3D islpci_mgt_transaction(priv->ndev, PIMFOR_OP_GET,
+					     oid, data, dlen, &response);
+		if (ret || !response ||
+		    response->header->operation =3D=3D PIMFOR_OP_ERROR) {
+			if (response)
+				islpci_mgt_release(response);
+			ret =3D -EIO;
+		}
+		if (!ret) {
+			_res =3D response->data;
+			reslen =3D response->header->length;
+		}
+	} else if (cache) {
+		_res =3D cache;
+		ret =3D 0;
+	}
+	if ((isl_oid[n].flags & OID_FLAG_TYPE) =3D=3D OID_TYPE_U32)
+		res->u =3D ret ? 0 : le32_to_cpu(*(u32 *) _res);
+	else {
+		res->ptr =3D kmalloc(reslen, GFP_KERNEL);
+		BUG_ON(res->ptr =3D=3D NULL);
+		if (ret)
+			memset(res->ptr, 0, reslen);
+		else {
+			memcpy(res->ptr, _res, reslen);
+			mgt_le_to_cpu(isl_oid[n].flags & OID_FLAG_TYPE,
+				      res->ptr);
+		}
+	}
+	if (cache)
+		up_read(&priv->mib_sem);
+
+	if (response && !ret)
+		islpci_mgt_release(response);
+
+	if (reslen > isl_oid[n].size)
+		printk(KERN_DEBUG
+		       "mgt_get_request(0x%x): received data length was bigger "
+		       "than expected (%d > %d). Memory is probably corrupted...",
+		       oid, reslen, isl_oid[n].size);
+
+	return ret;
+}
+
+/* lock outside */
+int
+mgt_commit_list(islpci_private *priv, enum oid_num_t *l, int n)
+{
+	int i, ret =3D 0;
+	struct islpci_mgmtframe *response;
+
+	for (i =3D 0; i < n; i++) {
+		struct oid_t *t =3D &(isl_oid[l[i]]);
+		void *data =3D priv->mib[l[i]];
+		int j =3D 0;
+		u32 oid =3D t->oid;
+		BUG_ON(data =3D=3D NULL);
+		while (j <=3D t->range) {
+			response =3D NULL;
+			ret |=3D islpci_mgt_transaction(priv->ndev, PIMFOR_OP_SET,
+						      oid, data, t->size,
+						      &response);
+			if (response) {
+				ret |=3D (response->header->operation =3D=3D
+					PIMFOR_OP_ERROR);
+				islpci_mgt_release(response);
+			}
+			j++;
+			oid++;
+			data +=3D t->size;
+		}
+	}
+	return ret;
+}
+
+/* Lock outside */
+
+void
+mgt_set(islpci_private *priv, enum oid_num_t n, void *data)
+{
+	BUG_ON(OID_NUM_LAST <=3D n);
+	BUG_ON(priv->mib[n] =3D=3D NULL);
+
+	memcpy(priv->mib[n], data, isl_oid[n].size);
+	mgt_cpu_to_le(isl_oid[n].flags & OID_FLAG_TYPE, priv->mib[n]);
+}
+
+void
+mgt_get(islpci_private *priv, enum oid_num_t n, void *res)
+{
+	BUG_ON(OID_NUM_LAST <=3D n);
+	BUG_ON(priv->mib[n] =3D=3D NULL);
+	BUG_ON(res =3D=3D NULL);
+
+	memcpy(res, priv->mib[n], isl_oid[n].size);
+	mgt_le_to_cpu(isl_oid[n].flags & OID_FLAG_TYPE, res);
+}
+
+/* Commits the cache. Lock outside. */
+
+static enum oid_num_t commit_part1[] =3D {
+	OID_INL_CONFIG,
+	OID_INL_MODE,
+	DOT11_OID_BSSTYPE,
+	DOT11_OID_CHANNEL,
+	DOT11_OID_MLMEAUTOLEVEL
+};
+
+static enum oid_num_t commit_part2[] =3D {
+	DOT11_OID_SSID,
+	DOT11_OID_PSMBUFFER,
+	DOT11_OID_AUTHENABLE,
+	DOT11_OID_PRIVACYINVOKED,
+	DOT11_OID_EXUNENCRYPTED,
+	DOT11_OID_DEFKEYX,	/* MULTIPLE */
+	DOT11_OID_DEFKEYID,
+	DOT11_OID_DOT1XENABLE,
+	OID_INL_DOT11D_CONFORMANCE,
+	OID_INL_OUTPUTPOWER,
+};
+
+/* update the MAC addr. */
+static int
+mgt_update_addr(islpci_private *priv)
+{
+	struct islpci_mgmtframe *res =3D NULL;
+	int ret;
+
+	ret =3D islpci_mgt_transaction(priv->ndev, PIMFOR_OP_GET,
+				     isl_oid[GEN_OID_MACADDRESS].oid, NULL,
+				     isl_oid[GEN_OID_MACADDRESS].size, &res);
+
+	if ((ret =3D=3D 0) && res && (res->header->operation !=3D PIMFOR_OP_ERROR=
))
+		memcpy(priv->ndev->dev_addr, res->data, 6);
+	else
+		ret =3D -EIO;
+	if (res)
+		islpci_mgt_release(res);
+
+	return ret;
+}
+
+void
+mgt_commit(islpci_private *priv)
+{
+	int rvalue;
+	u32 u;
+
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return;
+
+	rvalue =3D mgt_commit_list(priv, commit_part1,
+				 sizeof (commit_part1) /
+				 sizeof (commit_part1[0]));
+
+	if (priv->iw_mode !=3D IW_MODE_MONITOR)
+		rvalue |=3D mgt_commit_list(priv, commit_part2,
+					  sizeof (commit_part2) /
+					  sizeof (commit_part2[0]));
+
+	u =3D OID_INL_MODE;
+	rvalue |=3D mgt_commit_list(priv, &u, 1);
+	rvalue |=3D mgt_update_addr(priv);
+
+	if (rvalue) {
+		/* some request have failed. The device might be in an
+		   incoherent state. We should reset it ! */
+		printk(KERN_DEBUG "%s: mgt_commit has failed. Restart the "
+		       "device \n", priv->ndev->name);
+	}
+}
+
+/* This will tell you if you are allowed to answer a mlme(ex) request .*/
+
+int
+mgt_mlme_answer(islpci_private *priv)
+{
+	u32 mlmeautolevel;
+	/* Acquire a read lock because if we are in a mode change, it's
+	 * possible to answer true, while the card is leaving master to managed
+	 * mode. Answering to a mlme in this situation could hang the card.
+	 */
+	down_read(&priv->mib_sem);
+	mlmeautolevel =3D
+	    le32_to_cpu(*(u32 *) priv->mib[DOT11_OID_MLMEAUTOLEVEL]);
+	up_read(&priv->mib_sem);
+
+	return ((priv->iw_mode =3D=3D IW_MODE_MASTER) &&
+		(mlmeautolevel >=3D DOT11_MLME_INTERMEDIATE));
+}
+
+enum oid_num_t
+mgt_oidtonum(u32 oid)
+{
+	int i;
+
+	for (i =3D 0; i < OID_NUM_LAST; i++)
+		if (isl_oid[i].oid =3D=3D oid)
+			return i;
+
+	printk(KERN_DEBUG "looking for an unknown oid 0x%x", oid);
+
+	return OID_NUM_LAST;
+}
+
+int
+mgt_response_to_str(enum oid_num_t n, union oid_res_t *r, char *str)
+{
+	switch (isl_oid[n].flags & OID_FLAG_TYPE) {
+	case OID_TYPE_U32:
+		return snprintf(str, PRIV_STR_SIZE, "%u\n", r->u);
+		break;
+	case OID_TYPE_BUFFER:{
+			struct obj_buffer *buff =3D r->ptr;
+			return snprintf(str, PRIV_STR_SIZE,
+					"size=3D%u\naddr=3D0x%X\n", buff->size,
+					buff->addr);
+		}
+		break;
+	case OID_TYPE_BSS:{
+			struct obj_bss *bss =3D r->ptr;
+			return snprintf(str, PRIV_STR_SIZE,
+					"age=3D%u\nchannel=3D%u\n"
+					"capinfo=3D0x%X\nrates=3D0x%X\n"
+					"basic_rates=3D0x%X\n", bss->age,
+					bss->channel, bss->capinfo,
+					bss->rates, bss->basic_rates);
+		}
+		break;
+	case OID_TYPE_BSSLIST:{
+			struct obj_bsslist *list =3D r->ptr;
+			int i, k;
+			k =3D snprintf(str, PRIV_STR_SIZE, "nr=3D%u\n", list->nr);
+			for (i =3D 0; i < list->nr; i++)
+				k +=3D snprintf(str + k, PRIV_STR_SIZE - k,
+					      "bss[%u] : \nage=3D%u\nchannel=3D%u\n"
+					      "capinfo=3D0x%X\nrates=3D0x%X\n"
+					      "basic_rates=3D0x%X\n",
+					      i, list->bsslist[i].age,
+					      list->bsslist[i].channel,
+					      list->bsslist[i].capinfo,
+					      list->bsslist[i].rates,
+					      list->bsslist[i].basic_rates);
+			return k;
+		}
+		break;
+	case OID_TYPE_FREQUENCIES:{
+			struct obj_frequencies *freq =3D r->ptr;
+			int i, t;
+			printk("nr : %u\n", freq->nr);
+			t =3D snprintf(str, PRIV_STR_SIZE, "nr=3D%u\n", freq->nr);
+			for (i =3D 0; i < freq->nr; i++)
+				t +=3D snprintf(str + t, PRIV_STR_SIZE - t,
+					      "mhz[%u]=3D%u\n", i, freq->mhz[i]);
+			return t;
+		}
+		break;
+	case OID_TYPE_MLME:{
+			struct obj_mlme *mlme =3D r->ptr;
+			return snprintf(str, PRIV_STR_SIZE,
+					"id=3D0x%X\nstate=3D0x%X\ncode=3D0x%X\n",
+					mlme->id, mlme->state, mlme->code);
+		}
+		break;
+	case OID_TYPE_MLMEEX:{
+			struct obj_mlmeex *mlme =3D r->ptr;
+			return snprintf(str, PRIV_STR_SIZE,
+					"id=3D0x%X\nstate=3D0x%X\n"
+					"code=3D0x%X\nsize=3D0x%X\n", mlme->id,
+					mlme->state, mlme->code, mlme->size);
+		}
+		break;
+	case OID_TYPE_SSID:{
+			struct obj_ssid *ssid =3D r->ptr;
+			return snprintf(str, PRIV_STR_SIZE,
+					"length=3D%u\noctets=3D%.*s\n",
+					ssid->length, ssid->length,
+					ssid->octets);
+		}
+		break;
+	case OID_TYPE_KEY:{
+			struct obj_key *key =3D r->ptr;
+			int t, i;
+			t =3D snprintf(str, PRIV_STR_SIZE,
+				     "type=3D0x%X\nlength=3D0x%X\nkey=3D0x",
+				     key->type, key->length);
+			for (i =3D 0; i < key->length; i++)
+				t +=3D snprintf(str + t, PRIV_STR_SIZE - t,
+					      "%02X:", key->key[i]);
+			t +=3D snprintf(str + t, PRIV_STR_SIZE - t, "\n");
+			return t;
+		}
+		break;
+	case OID_TYPE_RAW:
+	case OID_TYPE_ADDR:{
+			unsigned char *buff =3D r->ptr;
+			int t, i;
+			t =3D snprintf(str, PRIV_STR_SIZE, "hex data=3D");
+			for (i =3D 0; i < isl_oid[n].size; i++)
+				t +=3D snprintf(str + t, PRIV_STR_SIZE - t,
+					      "%02X:", buff[i]);
+			t +=3D snprintf(str + t, PRIV_STR_SIZE - t, "\n");
+			return t;
+		}
+		break;
+	default:
+		BUG();
+	}
+	return 0;
+}
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/p=
rism54/oid_mgt.h linux-2.4.26-prism54/drivers/net/wireless/prism54/oid_mgt.h
--- linux-2.4.26/drivers/net/wireless/prism54/oid_mgt.h	1970-01-01 00:00:00=
.000000000 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/prism54/oid_mgt.h	2004-07-21 =
09:00:04.000000000 +0000
@@ -0,0 +1,58 @@
+/*
+ *  Copyright (C) 2003 Aurelien Alleaume <slts@free.fr>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ */
+
+#if !defined(_OID_MGT_H)
+#define _OID_MGT_H
+
+#include "isl_oid.h"
+#include "islpci_dev.h"
+
+extern struct oid_t isl_oid[];
+
+int mgt_init(islpci_private *);
+
+void mgt_clean(islpci_private *);
+
+/* I don't know where to put these 3 */
+extern const int frequency_list_bg[];
+extern const int frequency_list_a[];
+int channel_of_freq(int);
+
+void mgt_le_to_cpu(int, void *);
+
+int mgt_set_request(islpci_private *, enum oid_num_t, int, void *);
+
+int mgt_get_request(islpci_private *, enum oid_num_t, int, void *,
+		    union oid_res_t *);
+
+int mgt_commit_list(islpci_private *, enum oid_num_t *, int);
+
+void mgt_set(islpci_private *, enum oid_num_t, void *);
+
+void mgt_get(islpci_private *, enum oid_num_t, void *);
+
+void mgt_commit(islpci_private *);
+
+int mgt_mlme_answer(islpci_private *);
+
+enum oid_num_t mgt_oidtonum(u32 oid);
+
+int mgt_response_to_str(enum oid_num_t, union oid_res_t *, char *);
+
+#endif				/* !defined(_OID_MGT_H) */
+/* EOF */
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/p=
rism54/prismcompat.h linux-2.4.26-prism54/drivers/net/wireless/prism54/pris=
mcompat.h
--- linux-2.4.26/drivers/net/wireless/prism54/prismcompat.h	1970-01-01 00:0=
0:00.000000000 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/prism54/prismcompat.h	2004-07=
-21 09:00:04.000000000 +0000
@@ -0,0 +1,46 @@
+/* =20
+ *  (C) 2004 Margit Schubert-While <margitsw@t-online.de>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ */
+
+/* =20
+ *	Compatibility header file to aid support of different kernel versions
+ */
+
+#ifdef PRISM54_COMPAT24
+#include "prismcompat24.h"
+#else	/* PRISM54_COMPAT24 */
+
+#ifndef _PRISM_COMPAT_H
+#define _PRISM_COMPAT_H
+
+#include <linux/device.h>
+#include <linux/firmware.h>
+#include <linux/config.h>
+#include <linux/moduleparam.h>
+#include <linux/workqueue.h>
+#include <linux/compiler.h>
+
+#if !defined(CONFIG_FW_LOADER) && !defined(CONFIG_FW_LOADER_MODULE)
+#error Firmware Loading is not configured in the kernel !
+#endif
+
+#define prism54_synchronize_irq(irq) synchronize_irq(irq)
+
+#define PRISM_FW_PDEV		&priv->pdev->dev
+
+#endif				/* _PRISM_COMPAT_H */
+#endif				/* PRISM54_COMPAT24 */
diff -Naur -X /home/mcgrof/lib/dontdiff linux-2.4.26/drivers/net/wireless/p=
rism54/prismcompat24.h linux-2.4.26-prism54/drivers/net/wireless/prism54/pr=
ismcompat24.h
--- linux-2.4.26/drivers/net/wireless/prism54/prismcompat24.h	1970-01-01 00=
:00:00.000000000 +0000
+++ linux-2.4.26-prism54/drivers/net/wireless/prism54/prismcompat24.h	2004-=
07-21 09:00:04.000000000 +0000
@@ -0,0 +1,72 @@
+/* =20
+ *  (C) 2004 Margit Schubert-While <margitsw@t-online.de>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ */
+
+/* =20
+ *	Compatibility header file to aid support of different kernel versions
+ */
+
+#ifndef _PRISM_COMPAT_H
+#define _PRISM_COMPAT_H
+
+#include <linux/firmware.h>
+#include <linux/config.h>
+#include <linux/tqueue.h>
+#include <linux/version.h>
+#include <linux/compiler.h>
+#include <linux/netdevice.h>
+#include <asm/uaccess.h>
+
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,4,25)
+#define module_param(x, y, z)	MODULE_PARM(x, "i")
+#else
+#include <linux/moduleparam.h>
+#endif
+
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,4,23)
+#define free_netdev(x)		kfree(x)
+#define pci_name(x)		x->slot_name
+#define irqreturn_t		void
+#define IRQ_HANDLED
+#define IRQ_NONE
+#else
+#include <linux/interrupt.h>
+#endif
+
+#define work_struct		tq_struct
+#define INIT_WORK		INIT_TQUEUE
+#define schedule_work		schedule_task
+
+#if !defined(HAVE_NETDEV_PRIV)
+#define netdev_priv(x)		x->priv
+#endif
+
+#if !defined(CONFIG_FW_LOADER) && !defined(CONFIG_FW_LOADER_MODULE)
+#error Firmware Loading is not configured in the kernel !
+#endif
+
+#define prism54_synchronize_irq(irq) synchronize_irq()
+
+#define DEFINE_WAIT(y)			DECLARE_WAITQUEUE(y, current)
+#define prepare_to_wait(x, y, z)	set_current_state(z); \
+					add_wait_queue(x, y)
+#define finish_wait(x, y)		remove_wait_queue(x, y); \
+					set_current_state(TASK_RUNNING)
+
+#define PRISM_FW_PDEV		pci_name(priv->pdev)
+
+#endif				/* _PRISM_COMPAT_H */

--fUYQa+Pmc3FrFX/N--

--V0207lvV8h4k8FAm
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA/jiOat1JN+IKUl4RAp3xAJ0Q2m1hJlgNwIblex3byV1zchQbgQCeLuzz
8ILBB5dEwOdBo3cyx/7jnZQ=
=kDNL
-----END PGP SIGNATURE-----

--V0207lvV8h4k8FAm--

--===============1706733925==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============1706733925==--
