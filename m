From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 8/9] define global BIT macro
Date: Sat, 18 Aug 2007 11:44:12 +0200 (CEST)
Message-ID: <428714662539710215@wsc.cz>
References: <737828602404912540@wsc.cz>
Cc: <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-reply-to: <737828602404912540@wsc.cz>
Cc: <source@mvista.com>
Cc: <dougthompson@xmission.com>
Cc: <bluesmoke-devel@lists.sourceforge.net>
Cc: <dtor@mail.ru>
Cc: <linux-input@atrey.karlin.mff.cuni.cz>
Cc: <netdev@vger.kernel.org>
Cc: <James.Bottomley@SteelEye.com>
Cc: <linux-scsi@vger.kernel.org>
Cc: <gtolstolytkin@ru.mvista.com>
Cc: <vitalywool@gmail.com>
Cc: <dsaxena@plexity.net>
Cc: <ralf@linux-mips.org>
Cc: <linux-mips@linux-mips.org>
Cc: <mchehab@infradead.org>
Cc: <video4linux-list@redhat.com>
Cc: <jbenc@suse.cz>
Cc: <flamingice@sourmilk.net>
Cc: <linux-wireless@vger.kernel.org>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

define global BIT macro

move all local BIT defines to the new globally define macro.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>

---
commit 19b14b967521eda7011bd70891bbe5044882d739
tree cd49de4f9f8d991ee7af22037a86978ea227abb8
parent fef5bcc8e5a7bfd66920df6d02c3448314dfe4b2
author Jiri Slaby <jirislaby@gmail.com> Sat, 18 Aug 2007 11:16:36 +0200
committer Jiri Slaby <jirislaby@gmail.com> Sat, 18 Aug 2007 11:16:36 +0200

 arch/ppc/platforms/chestnut.c               |    1 -
 drivers/edac/edac_core.h                    |    2 --
 drivers/firmware/dcdbas.h                   |    2 --
 drivers/input/serio/maceps2.c               |    2 --
 drivers/net/eth16i.c                        |    1 -
 drivers/net/meth.h                          |    3 ---
 drivers/net/wireless/hostap/hostap_common.h |    2 --
 drivers/scsi/FlashPoint.c                   |    1 -
 drivers/scsi/nsp32.h                        |    5 -----
 drivers/scsi/pcmcia/nsp_cs.h                |    1 -
 drivers/video/pnx4008/sdum.h                |    3 ---
 include/asm-arm/arch-ixp4xx/io.h            |    3 ---
 include/asm-mips/ip32/crime.h               |    3 ---
 include/asm-mips/ip32/mace.h                |    3 ---
 include/linux/bitops.h                      |    1 +
 include/video/sstfb.h                       |    1 -
 include/video/tdfx.h                        |    2 --
 net/mac80211/ieee80211_i.h                  |    2 --
 18 files changed, 1 insertions(+), 37 deletions(-)

diff --git a/arch/ppc/platforms/chestnut.c b/arch/ppc/platforms/chestnut.c
index 4696849..ccd2faa 100644
--- a/arch/ppc/platforms/chestnut.c
+++ b/arch/ppc/platforms/chestnut.c
@@ -49,7 +49,6 @@ extern void gen550_progress(char *, unsigned short);
 extern void gen550_init(int, struct uart_port *);
 extern void mv64360_pcibios_fixup(mv64x60_handle_t *bh);
 
-#define BIT(x) (1<<x)
 #define CHESTNUT_PRESERVE_MASK (BIT(MV64x60_CPU2DEV_0_WIN) | \
 				BIT(MV64x60_CPU2DEV_1_WIN) | \
 				BIT(MV64x60_CPU2DEV_2_WIN) | \
diff --git a/drivers/edac/edac_core.h b/drivers/edac/edac_core.h
index 4e6bad1..309a1a5 100644
--- a/drivers/edac/edac_core.h
+++ b/drivers/edac/edac_core.h
@@ -94,8 +94,6 @@ extern int edac_debug_level;
 
 #endif				/* !CONFIG_EDAC_DEBUG */
 
-#define BIT(x) (1 << (x))
-
 #define PCI_VEND_DEV(vend, dev) PCI_VENDOR_ID_ ## vend, \
 	PCI_DEVICE_ID_ ## vend ## _ ## dev
 
diff --git a/drivers/firmware/dcdbas.h b/drivers/firmware/dcdbas.h
index 8960cad..87bc341 100644
--- a/drivers/firmware/dcdbas.h
+++ b/drivers/firmware/dcdbas.h
@@ -20,8 +20,6 @@
 #include <linux/sysfs.h>
 #include <linux/types.h>
 
-#define BIT(x)					(1UL << x)
-
 #define MAX_SMI_DATA_BUF_SIZE			(256 * 1024)
 
 #define HC_ACTION_NONE				(0)
diff --git a/drivers/input/serio/maceps2.c b/drivers/input/serio/maceps2.c
index 5a41b8f..558200e 100644
--- a/drivers/input/serio/maceps2.c
+++ b/drivers/input/serio/maceps2.c
@@ -31,8 +31,6 @@ MODULE_LICENSE("GPL");
 
 #define MACE_PS2_TIMEOUT 10000 /* in 50us unit */
 
-#define BIT(x) (1UL << (x))
-
 #define PS2_STATUS_CLOCK_SIGNAL  BIT(0) /* external clock signal */
 #define PS2_STATUS_CLOCK_INHIBIT BIT(1) /* clken output signal */
 #define PS2_STATUS_TX_INPROGRESS BIT(2) /* transmission in progress */
diff --git a/drivers/net/eth16i.c b/drivers/net/eth16i.c
index 04abf59..f613dae 100644
--- a/drivers/net/eth16i.c
+++ b/drivers/net/eth16i.c
@@ -170,7 +170,6 @@ static char *version =
 
 
 /* Few macros */
-#define BIT(a)		       ( (1 << (a)) )
 #define BITSET(ioaddr, bnum)   ((outb(((inb(ioaddr)) | (bnum)), ioaddr)))
 #define BITCLR(ioaddr, bnum)   ((outb(((inb(ioaddr)) & (~(bnum))), ioaddr)))
 
diff --git a/drivers/net/meth.h b/drivers/net/meth.h
index ea3b8fc..a78dc1c 100644
--- a/drivers/net/meth.h
+++ b/drivers/net/meth.h
@@ -28,9 +28,6 @@
 #define RX_BUFFER_OFFSET (sizeof(rx_status_vector)+2) /* staus vector + 2 bytes of padding */
 #define RX_BUCKET_SIZE 256
 
-#undef BIT
-#define BIT(x)	(1UL << (x))
-
 /* For more detailed explanations of what each field menas,
    see Nick's great comments to #defines below (or docs, if
    you are lucky enough toget hold of them :)*/
diff --git a/drivers/net/wireless/hostap/hostap_common.h b/drivers/net/wireless/hostap/hostap_common.h
index b31e6a0..f3930f9 100644
--- a/drivers/net/wireless/hostap/hostap_common.h
+++ b/drivers/net/wireless/hostap/hostap_common.h
@@ -4,8 +4,6 @@
 #include <linux/types.h>
 #include <linux/if_ether.h>
 
-#define BIT(x) (1 << (x))
-
 #define MAC2STR(a) (a)[0], (a)[1], (a)[2], (a)[3], (a)[4], (a)[5]
 #define MACSTR "%02x:%02x:%02x:%02x:%02x:%02x"
 
diff --git a/drivers/scsi/FlashPoint.c b/drivers/scsi/FlashPoint.c
index a7f916c..cf549ff 100644
--- a/drivers/scsi/FlashPoint.c
+++ b/drivers/scsi/FlashPoint.c
@@ -25,7 +25,6 @@
 
 #define FAILURE         0xFFFFFFFFL
 
-#define BIT(x)          ((unsigned char)(1<<(x)))	/* single-bit mask in bit position x */
 #define BITW(x)          ((unsigned short)(1<<(x)))	/* single-bit mask in bit position x */
 
 struct sccb;
diff --git a/drivers/scsi/nsp32.h b/drivers/scsi/nsp32.h
index a976e81..6715ecb 100644
--- a/drivers/scsi/nsp32.h
+++ b/drivers/scsi/nsp32.h
@@ -69,11 +69,6 @@ typedef u32 u32_le;
 typedef u16 u16_le;
 
 /*
- * MACRO
- */
-#define BIT(x)      (1UL << (x))
-
-/*
  * BASIC Definitions
  */
 #ifndef TRUE
diff --git a/drivers/scsi/pcmcia/nsp_cs.h b/drivers/scsi/pcmcia/nsp_cs.h
index b7f0fa2..9839755 100644
--- a/drivers/scsi/pcmcia/nsp_cs.h
+++ b/drivers/scsi/pcmcia/nsp_cs.h
@@ -24,7 +24,6 @@
 /************************************
  * Some useful macros...
  */
-#define BIT(x)      (1L << (x))
 
 /* SCSI initiator must be ID 7 */
 #define NSP_INITIATOR_ID  7
diff --git a/drivers/video/pnx4008/sdum.h b/drivers/video/pnx4008/sdum.h
index e8c5dcd..189c3d6 100644
--- a/drivers/video/pnx4008/sdum.h
+++ b/drivers/video/pnx4008/sdum.h
@@ -77,9 +77,6 @@
 #define CONF_DIRTYDETECTION_OFF	(0x600)
 #define CONF_DIRTYDETECTION_ON	(0x601)
 
-/* Set the corresponding bit. */
-#define BIT(n) (0x1U << (n))
-
 struct dumchannel_uf {
 	int channelnr;
 	u32 *dirty;
diff --git a/include/asm-arm/arch-ixp4xx/io.h b/include/asm-arm/arch-ixp4xx/io.h
index c72f9d7..eeeea90 100644
--- a/include/asm-arm/arch-ixp4xx/io.h
+++ b/include/asm-arm/arch-ixp4xx/io.h
@@ -17,9 +17,6 @@
 
 #define IO_SPACE_LIMIT 0xffff0000
 
-#define	BIT(x)	((1)<<(x))
-
-
 extern int (*ixp4xx_pci_read)(u32 addr, u32 cmd, u32* data);
 extern int ixp4xx_pci_write(u32 addr, u32 cmd, u32 data);
 
diff --git a/include/asm-mips/ip32/crime.h b/include/asm-mips/ip32/crime.h
index a13702f..7c36b0e 100644
--- a/include/asm-mips/ip32/crime.h
+++ b/include/asm-mips/ip32/crime.h
@@ -17,9 +17,6 @@
  */
 #define CRIME_BASE	0x14000000	/* physical */
 
-#undef BIT
-#define BIT(x)	(1UL << (x))
-
 struct sgi_crime {
 	volatile unsigned long id;
 #define CRIME_ID_MASK			0xff
diff --git a/include/asm-mips/ip32/mace.h b/include/asm-mips/ip32/mace.h
index 990082c..d08d7c6 100644
--- a/include/asm-mips/ip32/mace.h
+++ b/include/asm-mips/ip32/mace.h
@@ -17,9 +17,6 @@
  */
 #define MACE_BASE	0x1f000000	/* physical */
 
-#undef BIT
-#define BIT(x) (1UL << (x))
-
 /*
  * PCI interface
  */
diff --git a/include/linux/bitops.h b/include/linux/bitops.h
index 3255b06..a57b81f 100644
--- a/include/linux/bitops.h
+++ b/include/linux/bitops.h
@@ -3,6 +3,7 @@
 #include <asm/types.h>
 
 #ifdef	__KERNEL__
+#define BIT(nr)			(1UL << (nr))
 #define BIT_MASK(nr)		(1UL << ((nr) % BITS_PER_LONG))
 #define BIT_WORD(nr)		((nr) / BITS_PER_LONG)
 #define BITS_TO_TYPE(nr, t)	(((nr)+(t)-1)/(t))
diff --git a/include/video/sstfb.h b/include/video/sstfb.h
index baa163f..b52f073 100644
--- a/include/video/sstfb.h
+++ b/include/video/sstfb.h
@@ -68,7 +68,6 @@
 #  define print_var(X,Y...)
 #endif
 
-#define BIT(x)		(1ul<<(x))
 #define POW2(x)		(1ul<<(x))
 
 /*
diff --git a/include/video/tdfx.h b/include/video/tdfx.h
index 05b63c2..7431d96 100644
--- a/include/video/tdfx.h
+++ b/include/video/tdfx.h
@@ -79,8 +79,6 @@
 
 /* register bitfields (not all, only as needed) */
 
-#define BIT(x)	(1UL << (x))
-
 /* COMMAND_2D reg. values */
 #define TDFX_ROP_COPY		0xcc	/* src */
 #define TDFX_ROP_INVERT		0x55	/* NOT dst */
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 54172a7..39d6ad1 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -36,8 +36,6 @@
 
 struct ieee80211_local;
 
-#define BIT(x) (1 << (x))
-
 #define IEEE80211_ALIGN32_PAD(a) ((4 - ((a) & 3)) & 3)
 
 /* Maximum number of broadcast/multicast frames to buffer when some of the
