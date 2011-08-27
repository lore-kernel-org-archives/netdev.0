From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/10] fddi: Move the FDDI drivers
Date: Sat, 27 Aug 2011 02:55:07 -0700
Message-ID: <1314438916-2478-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314438916-2478-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, "Maciej W. Rozycki" <macro@linux-mips.org>,
	Christoph Goos <cgoos@syskonnect.de>, <linux@syskonnect.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17525 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750871Ab1H0JzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Aug 2011 05:55:20 -0400
In-Reply-To: <1314438916-2478-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the FDDI drivers into drivers/net/fddi/ and make the
necessary Kconfig and Makefile changes.

CC: "Maciej W. Rozycki" <macro@linux-mips.org>
CC: Christoph Goos <cgoos@syskonnect.de>
CC: <linux@syskonnect.de>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                              |    2 +-
 drivers/net/Kconfig                      |   72 +---------------------------
 drivers/net/Makefile                     |    3 +-
 drivers/net/fddi/Kconfig                 |   77 ++++++++++++++++++++++++++++++
 drivers/net/fddi/Makefile                |    6 ++
 drivers/net/{ => fddi}/defxx.c           |    0
 drivers/net/{ => fddi}/defxx.h           |    0
 drivers/net/{ => fddi}/skfp/Makefile     |    0
 drivers/net/{ => fddi}/skfp/cfm.c        |    0
 drivers/net/{ => fddi}/skfp/drvfbi.c     |    0
 drivers/net/{ => fddi}/skfp/ecm.c        |    0
 drivers/net/{ => fddi}/skfp/ess.c        |    0
 drivers/net/{ => fddi}/skfp/fplustm.c    |    0
 drivers/net/{ => fddi}/skfp/h/cmtdef.h   |    0
 drivers/net/{ => fddi}/skfp/h/fddi.h     |    0
 drivers/net/{ => fddi}/skfp/h/fddimib.h  |    0
 drivers/net/{ => fddi}/skfp/h/fplustm.h  |    0
 drivers/net/{ => fddi}/skfp/h/hwmtm.h    |    0
 drivers/net/{ => fddi}/skfp/h/mbuf.h     |    0
 drivers/net/{ => fddi}/skfp/h/osdef1st.h |    0
 drivers/net/{ => fddi}/skfp/h/sba.h      |    0
 drivers/net/{ => fddi}/skfp/h/sba_def.h  |    0
 drivers/net/{ => fddi}/skfp/h/skfbi.h    |    0
 drivers/net/{ => fddi}/skfp/h/skfbiinc.h |    0
 drivers/net/{ => fddi}/skfp/h/smc.h      |    0
 drivers/net/{ => fddi}/skfp/h/smt.h      |    0
 drivers/net/{ => fddi}/skfp/h/smt_p.h    |    0
 drivers/net/{ => fddi}/skfp/h/smtstate.h |    0
 drivers/net/{ => fddi}/skfp/h/supern_2.h |    0
 drivers/net/{ => fddi}/skfp/h/targethw.h |    0
 drivers/net/{ => fddi}/skfp/h/targetos.h |    0
 drivers/net/{ => fddi}/skfp/h/types.h    |    0
 drivers/net/{ => fddi}/skfp/hwmtm.c      |    0
 drivers/net/{ => fddi}/skfp/hwt.c        |    0
 drivers/net/{ => fddi}/skfp/pcmplc.c     |    0
 drivers/net/{ => fddi}/skfp/pmf.c        |    0
 drivers/net/{ => fddi}/skfp/queue.c      |    0
 drivers/net/{ => fddi}/skfp/rmt.c        |    0
 drivers/net/{ => fddi}/skfp/skfddi.c     |    0
 drivers/net/{ => fddi}/skfp/smt.c        |    0
 drivers/net/{ => fddi}/skfp/smtdef.c     |    0
 drivers/net/{ => fddi}/skfp/smtinit.c    |    0
 drivers/net/{ => fddi}/skfp/smttimer.c   |    0
 drivers/net/{ => fddi}/skfp/srf.c        |    0
 44 files changed, 87 insertions(+), 73 deletions(-)
 create mode 100644 drivers/net/fddi/Kconfig
 create mode 100644 drivers/net/fddi/Makefile
 rename drivers/net/{ => fddi}/defxx.c (100%)
 rename drivers/net/{ => fddi}/defxx.h (100%)
 rename drivers/net/{ => fddi}/skfp/Makefile (100%)
 rename drivers/net/{ => fddi}/skfp/cfm.c (100%)
 rename drivers/net/{ => fddi}/skfp/drvfbi.c (100%)
 rename drivers/net/{ => fddi}/skfp/ecm.c (100%)
 rename drivers/net/{ => fddi}/skfp/ess.c (100%)
 rename drivers/net/{ => fddi}/skfp/fplustm.c (100%)
 rename drivers/net/{ => fddi}/skfp/h/cmtdef.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/fddi.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/fddimib.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/fplustm.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/hwmtm.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/mbuf.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/osdef1st.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/sba.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/sba_def.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/skfbi.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/skfbiinc.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/smc.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/smt.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/smt_p.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/smtstate.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/supern_2.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/targethw.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/targetos.h (100%)
 rename drivers/net/{ => fddi}/skfp/h/types.h (100%)
 rename drivers/net/{ => fddi}/skfp/hwmtm.c (100%)
 rename drivers/net/{ => fddi}/skfp/hwt.c (100%)
 rename drivers/net/{ => fddi}/skfp/pcmplc.c (100%)
 rename drivers/net/{ => fddi}/skfp/pmf.c (100%)
 rename drivers/net/{ => fddi}/skfp/queue.c (100%)
 rename drivers/net/{ => fddi}/skfp/rmt.c (100%)
 rename drivers/net/{ => fddi}/skfp/skfddi.c (100%)
 rename drivers/net/{ => fddi}/skfp/smt.c (100%)
 rename drivers/net/{ => fddi}/skfp/smtdef.c (100%)
 rename drivers/net/{ => fddi}/skfp/smtinit.c (100%)
 rename drivers/net/{ => fddi}/skfp/smttimer.c (100%)
 rename drivers/net/{ => fddi}/skfp/srf.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index d32e1ca..2777088 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2113,7 +2113,7 @@ F:	net/decnet/
 DEFXX FDDI NETWORK DRIVER
 M:	"Maciej W. Rozycki" <macro@linux-mips.org>
 S:	Maintained
-F:	drivers/net/defxx.*
+F:	drivers/net/fddi/defxx.*
 
 DELL LAPTOP DRIVER
 M:	Matthew Garrett <mjg59@srcf.ucam.org>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ef6b6be..7bdc22b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -195,6 +195,8 @@ config SUNGEM_PHY
 
 source "drivers/net/ethernet/Kconfig"
 
+source "drivers/net/fddi/Kconfig"
+
 source "drivers/net/tokenring/Kconfig"
 
 source "drivers/net/wireless/Kconfig"
@@ -268,76 +270,6 @@ config RIONET_RX_SIZE
 	depends on RIONET
 	default "128"
 
-config FDDI
-	tristate "FDDI driver support"
-	depends on (PCI || EISA || TC)
-	help
-	  Fiber Distributed Data Interface is a high speed local area network
-	  design; essentially a replacement for high speed Ethernet. FDDI can
-	  run over copper or fiber. If you are connected to such a network and
-	  want a driver for the FDDI card in your computer, say Y here (and
-	  then also Y to the driver for your FDDI card, below). Most people
-	  will say N.
-
-config DEFXX
-	tristate "Digital DEFTA/DEFEA/DEFPA adapter support"
-	depends on FDDI && (PCI || EISA || TC)
-	---help---
-	  This is support for the DIGITAL series of TURBOchannel (DEFTA),
-	  EISA (DEFEA) and PCI (DEFPA) controllers which can connect you
-	  to a local FDDI network.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called defxx.  If unsure, say N.
-
-config DEFXX_MMIO
-	bool
-	prompt "Use MMIO instead of PIO" if PCI || EISA
-	depends on DEFXX
-	default n if PCI || EISA
-	default y
-	---help---
-	  This instructs the driver to use EISA or PCI memory-mapped I/O
-	  (MMIO) as appropriate instead of programmed I/O ports (PIO).
-	  Enabling this gives an improvement in processing time in parts
-	  of the driver, but it may cause problems with EISA (DEFEA)
-	  adapters.  TURBOchannel does not have the concept of I/O ports,
-	  so MMIO is always used for these (DEFTA) adapters.
-
-	  If unsure, say N.
-
-config SKFP
-	tristate "SysKonnect FDDI PCI support"
-	depends on FDDI && PCI
-	select BITREVERSE
-	---help---
-	  Say Y here if you have a SysKonnect FDDI PCI adapter.
-	  The following adapters are supported by this driver:
-	  - SK-5521 (SK-NET FDDI-UP)
-	  - SK-5522 (SK-NET FDDI-UP DAS)
-	  - SK-5541 (SK-NET FDDI-FP)
-	  - SK-5543 (SK-NET FDDI-LP)
-	  - SK-5544 (SK-NET FDDI-LP DAS)
-	  - SK-5821 (SK-NET FDDI-UP64)
-	  - SK-5822 (SK-NET FDDI-UP64 DAS)
-	  - SK-5841 (SK-NET FDDI-FP64)
-	  - SK-5843 (SK-NET FDDI-LP64)
-	  - SK-5844 (SK-NET FDDI-LP64 DAS)
-	  - Netelligent 100 FDDI DAS Fibre SC
-	  - Netelligent 100 FDDI SAS Fibre SC
-	  - Netelligent 100 FDDI DAS UTP
-	  - Netelligent 100 FDDI SAS UTP
-	  - Netelligent 100 FDDI SAS Fibre MIC
-
-	  Read <file:Documentation/networking/skfp.txt> for information about
-	  the driver.
-
-	  Questions concerning this driver can be addressed to:
-	  <linux@syskonnect.de>
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called skfp.  This is recommended.
-
 config HIPPI
 	bool "HIPPI driver support (EXPERIMENTAL)"
 	depends on EXPERIMENTAL && INET && PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index c33009b..3087b27 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -14,7 +14,6 @@ obj-$(CONFIG_VMXNET3) += vmxnet3/
 #
 obj-$(CONFIG_PLIP) += plip.o
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
-obj-$(CONFIG_SKFP) += skfp/
 obj-$(CONFIG_RIONET) += rionet.o
 
 #
@@ -42,13 +41,13 @@ obj-$(CONFIG_DUMMY) += dummy.o
 obj-$(CONFIG_IFB) += ifb.o
 obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
-obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_ETHERNET) += ethernet/
+obj-$(CONFIG_FDDI) += fddi/
 obj-$(CONFIG_TR) += tokenring/
 obj-$(CONFIG_WAN) += wan/
 obj-$(CONFIG_ARCNET) += arcnet/
diff --git a/drivers/net/fddi/Kconfig b/drivers/net/fddi/Kconfig
new file mode 100644
index 0000000..3a424c8
--- /dev/null
+++ b/drivers/net/fddi/Kconfig
@@ -0,0 +1,77 @@
+#
+# FDDI network device configuration
+#
+
+config FDDI
+	tristate "FDDI driver support"
+	depends on PCI || EISA || TC
+	---help---
+	  Fiber Distributed Data Interface is a high speed local area network
+	  design; essentially a replacement for high speed Ethernet. FDDI can
+	  run over copper or fiber. If you are connected to such a network and
+	  want a driver for the FDDI card in your computer, say Y here (and
+	  then also Y to the driver for your FDDI card, below). Most people
+	  will say N.
+
+if FDDI
+
+config DEFXX
+	tristate "Digital DEFTA/DEFEA/DEFPA adapter support"
+	depends on FDDI && (PCI || EISA || TC)
+	---help---
+	  This is support for the DIGITAL series of TURBOchannel (DEFTA),
+	  EISA (DEFEA) and PCI (DEFPA) controllers which can connect you
+	  to a local FDDI network.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called defxx.  If unsure, say N.
+
+config DEFXX_MMIO
+	bool
+	prompt "Use MMIO instead of PIO" if PCI || EISA
+	depends on DEFXX
+	default n if PCI || EISA
+	default y
+	---help---
+	  This instructs the driver to use EISA or PCI memory-mapped I/O
+	  (MMIO) as appropriate instead of programmed I/O ports (PIO).
+	  Enabling this gives an improvement in processing time in parts
+	  of the driver, but it may cause problems with EISA (DEFEA)
+	  adapters.  TURBOchannel does not have the concept of I/O ports,
+	  so MMIO is always used for these (DEFTA) adapters.
+
+	  If unsure, say N.
+
+config SKFP
+	tristate "SysKonnect FDDI PCI support"
+	depends on FDDI && PCI
+	select BITREVERSE
+	---help---
+	  Say Y here if you have a SysKonnect FDDI PCI adapter.
+	  The following adapters are supported by this driver:
+	  - SK-5521 (SK-NET FDDI-UP)
+	  - SK-5522 (SK-NET FDDI-UP DAS)
+	  - SK-5541 (SK-NET FDDI-FP)
+	  - SK-5543 (SK-NET FDDI-LP)
+	  - SK-5544 (SK-NET FDDI-LP DAS)
+	  - SK-5821 (SK-NET FDDI-UP64)
+	  - SK-5822 (SK-NET FDDI-UP64 DAS)
+	  - SK-5841 (SK-NET FDDI-FP64)
+	  - SK-5843 (SK-NET FDDI-LP64)
+	  - SK-5844 (SK-NET FDDI-LP64 DAS)
+	  - Netelligent 100 FDDI DAS Fibre SC
+	  - Netelligent 100 FDDI SAS Fibre SC
+	  - Netelligent 100 FDDI DAS UTP
+	  - Netelligent 100 FDDI SAS UTP
+	  - Netelligent 100 FDDI SAS Fibre MIC
+
+	  Read <file:Documentation/networking/skfp.txt> for information about
+	  the driver.
+
+	  Questions concerning this driver can be addressed to:
+	  <linux@syskonnect.de>
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called skfp.  This is recommended.
+
+endif # FDDI
diff --git a/drivers/net/fddi/Makefile b/drivers/net/fddi/Makefile
new file mode 100644
index 0000000..36da19c
--- /dev/null
+++ b/drivers/net/fddi/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the Linux FDDI network device drivers.
+#
+
+obj-$(CONFIG_DEFXX) += defxx.o
+obj-$(CONFIG_SKFP) += skfp/
diff --git a/drivers/net/defxx.c b/drivers/net/fddi/defxx.c
similarity index 100%
rename from drivers/net/defxx.c
rename to drivers/net/fddi/defxx.c
diff --git a/drivers/net/defxx.h b/drivers/net/fddi/defxx.h
similarity index 100%
rename from drivers/net/defxx.h
rename to drivers/net/fddi/defxx.h
diff --git a/drivers/net/skfp/Makefile b/drivers/net/fddi/skfp/Makefile
similarity index 100%
rename from drivers/net/skfp/Makefile
rename to drivers/net/fddi/skfp/Makefile
diff --git a/drivers/net/skfp/cfm.c b/drivers/net/fddi/skfp/cfm.c
similarity index 100%
rename from drivers/net/skfp/cfm.c
rename to drivers/net/fddi/skfp/cfm.c
diff --git a/drivers/net/skfp/drvfbi.c b/drivers/net/fddi/skfp/drvfbi.c
similarity index 100%
rename from drivers/net/skfp/drvfbi.c
rename to drivers/net/fddi/skfp/drvfbi.c
diff --git a/drivers/net/skfp/ecm.c b/drivers/net/fddi/skfp/ecm.c
similarity index 100%
rename from drivers/net/skfp/ecm.c
rename to drivers/net/fddi/skfp/ecm.c
diff --git a/drivers/net/skfp/ess.c b/drivers/net/fddi/skfp/ess.c
similarity index 100%
rename from drivers/net/skfp/ess.c
rename to drivers/net/fddi/skfp/ess.c
diff --git a/drivers/net/skfp/fplustm.c b/drivers/net/fddi/skfp/fplustm.c
similarity index 100%
rename from drivers/net/skfp/fplustm.c
rename to drivers/net/fddi/skfp/fplustm.c
diff --git a/drivers/net/skfp/h/cmtdef.h b/drivers/net/fddi/skfp/h/cmtdef.h
similarity index 100%
rename from drivers/net/skfp/h/cmtdef.h
rename to drivers/net/fddi/skfp/h/cmtdef.h
diff --git a/drivers/net/skfp/h/fddi.h b/drivers/net/fddi/skfp/h/fddi.h
similarity index 100%
rename from drivers/net/skfp/h/fddi.h
rename to drivers/net/fddi/skfp/h/fddi.h
diff --git a/drivers/net/skfp/h/fddimib.h b/drivers/net/fddi/skfp/h/fddimib.h
similarity index 100%
rename from drivers/net/skfp/h/fddimib.h
rename to drivers/net/fddi/skfp/h/fddimib.h
diff --git a/drivers/net/skfp/h/fplustm.h b/drivers/net/fddi/skfp/h/fplustm.h
similarity index 100%
rename from drivers/net/skfp/h/fplustm.h
rename to drivers/net/fddi/skfp/h/fplustm.h
diff --git a/drivers/net/skfp/h/hwmtm.h b/drivers/net/fddi/skfp/h/hwmtm.h
similarity index 100%
rename from drivers/net/skfp/h/hwmtm.h
rename to drivers/net/fddi/skfp/h/hwmtm.h
diff --git a/drivers/net/skfp/h/mbuf.h b/drivers/net/fddi/skfp/h/mbuf.h
similarity index 100%
rename from drivers/net/skfp/h/mbuf.h
rename to drivers/net/fddi/skfp/h/mbuf.h
diff --git a/drivers/net/skfp/h/osdef1st.h b/drivers/net/fddi/skfp/h/osdef1st.h
similarity index 100%
rename from drivers/net/skfp/h/osdef1st.h
rename to drivers/net/fddi/skfp/h/osdef1st.h
diff --git a/drivers/net/skfp/h/sba.h b/drivers/net/fddi/skfp/h/sba.h
similarity index 100%
rename from drivers/net/skfp/h/sba.h
rename to drivers/net/fddi/skfp/h/sba.h
diff --git a/drivers/net/skfp/h/sba_def.h b/drivers/net/fddi/skfp/h/sba_def.h
similarity index 100%
rename from drivers/net/skfp/h/sba_def.h
rename to drivers/net/fddi/skfp/h/sba_def.h
diff --git a/drivers/net/skfp/h/skfbi.h b/drivers/net/fddi/skfp/h/skfbi.h
similarity index 100%
rename from drivers/net/skfp/h/skfbi.h
rename to drivers/net/fddi/skfp/h/skfbi.h
diff --git a/drivers/net/skfp/h/skfbiinc.h b/drivers/net/fddi/skfp/h/skfbiinc.h
similarity index 100%
rename from drivers/net/skfp/h/skfbiinc.h
rename to drivers/net/fddi/skfp/h/skfbiinc.h
diff --git a/drivers/net/skfp/h/smc.h b/drivers/net/fddi/skfp/h/smc.h
similarity index 100%
rename from drivers/net/skfp/h/smc.h
rename to drivers/net/fddi/skfp/h/smc.h
diff --git a/drivers/net/skfp/h/smt.h b/drivers/net/fddi/skfp/h/smt.h
similarity index 100%
rename from drivers/net/skfp/h/smt.h
rename to drivers/net/fddi/skfp/h/smt.h
diff --git a/drivers/net/skfp/h/smt_p.h b/drivers/net/fddi/skfp/h/smt_p.h
similarity index 100%
rename from drivers/net/skfp/h/smt_p.h
rename to drivers/net/fddi/skfp/h/smt_p.h
diff --git a/drivers/net/skfp/h/smtstate.h b/drivers/net/fddi/skfp/h/smtstate.h
similarity index 100%
rename from drivers/net/skfp/h/smtstate.h
rename to drivers/net/fddi/skfp/h/smtstate.h
diff --git a/drivers/net/skfp/h/supern_2.h b/drivers/net/fddi/skfp/h/supern_2.h
similarity index 100%
rename from drivers/net/skfp/h/supern_2.h
rename to drivers/net/fddi/skfp/h/supern_2.h
diff --git a/drivers/net/skfp/h/targethw.h b/drivers/net/fddi/skfp/h/targethw.h
similarity index 100%
rename from drivers/net/skfp/h/targethw.h
rename to drivers/net/fddi/skfp/h/targethw.h
diff --git a/drivers/net/skfp/h/targetos.h b/drivers/net/fddi/skfp/h/targetos.h
similarity index 100%
rename from drivers/net/skfp/h/targetos.h
rename to drivers/net/fddi/skfp/h/targetos.h
diff --git a/drivers/net/skfp/h/types.h b/drivers/net/fddi/skfp/h/types.h
similarity index 100%
rename from drivers/net/skfp/h/types.h
rename to drivers/net/fddi/skfp/h/types.h
diff --git a/drivers/net/skfp/hwmtm.c b/drivers/net/fddi/skfp/hwmtm.c
similarity index 100%
rename from drivers/net/skfp/hwmtm.c
rename to drivers/net/fddi/skfp/hwmtm.c
diff --git a/drivers/net/skfp/hwt.c b/drivers/net/fddi/skfp/hwt.c
similarity index 100%
rename from drivers/net/skfp/hwt.c
rename to drivers/net/fddi/skfp/hwt.c
diff --git a/drivers/net/skfp/pcmplc.c b/drivers/net/fddi/skfp/pcmplc.c
similarity index 100%
rename from drivers/net/skfp/pcmplc.c
rename to drivers/net/fddi/skfp/pcmplc.c
diff --git a/drivers/net/skfp/pmf.c b/drivers/net/fddi/skfp/pmf.c
similarity index 100%
rename from drivers/net/skfp/pmf.c
rename to drivers/net/fddi/skfp/pmf.c
diff --git a/drivers/net/skfp/queue.c b/drivers/net/fddi/skfp/queue.c
similarity index 100%
rename from drivers/net/skfp/queue.c
rename to drivers/net/fddi/skfp/queue.c
diff --git a/drivers/net/skfp/rmt.c b/drivers/net/fddi/skfp/rmt.c
similarity index 100%
rename from drivers/net/skfp/rmt.c
rename to drivers/net/fddi/skfp/rmt.c
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/fddi/skfp/skfddi.c
similarity index 100%
rename from drivers/net/skfp/skfddi.c
rename to drivers/net/fddi/skfp/skfddi.c
diff --git a/drivers/net/skfp/smt.c b/drivers/net/fddi/skfp/smt.c
similarity index 100%
rename from drivers/net/skfp/smt.c
rename to drivers/net/fddi/skfp/smt.c
diff --git a/drivers/net/skfp/smtdef.c b/drivers/net/fddi/skfp/smtdef.c
similarity index 100%
rename from drivers/net/skfp/smtdef.c
rename to drivers/net/fddi/skfp/smtdef.c
diff --git a/drivers/net/skfp/smtinit.c b/drivers/net/fddi/skfp/smtinit.c
similarity index 100%
rename from drivers/net/skfp/smtinit.c
rename to drivers/net/fddi/skfp/smtinit.c
diff --git a/drivers/net/skfp/smttimer.c b/drivers/net/fddi/skfp/smttimer.c
similarity index 100%
rename from drivers/net/skfp/smttimer.c
rename to drivers/net/fddi/skfp/smttimer.c
diff --git a/drivers/net/skfp/srf.c b/drivers/net/fddi/skfp/srf.c
similarity index 100%
rename from drivers/net/skfp/srf.c
rename to drivers/net/fddi/skfp/srf.c
-- 
1.7.6
