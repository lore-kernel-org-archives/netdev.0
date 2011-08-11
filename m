From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/10] enic: Move the Cisco driver
Date: Thu, 11 Aug 2011 02:51:34 -0700
Message-ID: <1313056294-28426-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313056294-28426-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Christian Benvenuti <benve@cisco.com>,
	Vasanthy Kolluri <vkolluri@cisco.com>,
	Roopa Prabhu <roprabhu@cisco.com>,
	David Wang <dwang2@cisco.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16531 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755022Ab1HKJvp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 05:51:45 -0400
In-Reply-To: <1313056294-28426-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Cisco driver into drivers/net/ethernet/cisco/ and make the
necessary Kconfig and Makefile changes.

CC: Christian Benvenuti <benve@cisco.com>
CC: Vasanthy Kolluri <vkolluri@cisco.com>
CC: Roopa Prabhu <roprabhu@cisco.com>
CC: David Wang <dwang2@cisco.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    2 +-
 drivers/net/Kconfig                                |    6 -----
 drivers/net/Makefile                               |    1 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/cisco/Kconfig                 |   22 ++++++++++++++++++++
 drivers/net/ethernet/cisco/Makefile                |    5 ++++
 drivers/net/ethernet/cisco/enic/Kconfig            |    9 ++++++++
 drivers/net/{ => ethernet/cisco}/enic/Makefile     |    0
 drivers/net/{ => ethernet/cisco}/enic/cq_desc.h    |    0
 .../net/{ => ethernet/cisco}/enic/cq_enet_desc.h   |    0
 drivers/net/{ => ethernet/cisco}/enic/enic.h       |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_dev.c   |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_dev.h   |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_main.c  |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_pp.c    |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_pp.h    |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_res.c   |    0
 drivers/net/{ => ethernet/cisco}/enic/enic_res.h   |    0
 .../net/{ => ethernet/cisco}/enic/rq_enet_desc.h   |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_cq.c    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_cq.h    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_dev.c   |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_dev.h   |    0
 .../net/{ => ethernet/cisco}/enic/vnic_devcmd.h    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_enet.h  |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_intr.c  |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_intr.h  |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_nic.h   |    0
 .../net/{ => ethernet/cisco}/enic/vnic_resource.h  |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_rq.c    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_rq.h    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_rss.h   |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_stats.h |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_vic.c   |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_vic.h   |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_wq.c    |    0
 drivers/net/{ => ethernet/cisco}/enic/vnic_wq.h    |    0
 .../net/{ => ethernet/cisco}/enic/wq_enet_desc.h   |    0
 39 files changed, 39 insertions(+), 8 deletions(-)
 create mode 100644 drivers/net/ethernet/cisco/Kconfig
 create mode 100644 drivers/net/ethernet/cisco/Makefile
 create mode 100644 drivers/net/ethernet/cisco/enic/Kconfig
 rename drivers/net/{ => ethernet/cisco}/enic/Makefile (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/cq_desc.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/cq_enet_desc.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_dev.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_dev.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_main.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_pp.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_pp.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_res.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/enic_res.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/rq_enet_desc.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_cq.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_cq.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_dev.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_dev.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_devcmd.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_enet.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_intr.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_intr.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_nic.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_resource.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_rq.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_rq.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_rss.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_stats.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_vic.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_vic.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_wq.c (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/vnic_wq.h (100%)
 rename drivers/net/{ => ethernet/cisco}/enic/wq_enet_desc.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2fcfa8b..c54e736 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1761,7 +1761,7 @@ M:	Vasanthy Kolluri <vkolluri@cisco.com>
 M:	Roopa Prabhu <roprabhu@cisco.com>
 M:	David Wang <dwang2@cisco.com>
 S:	Supported
-F:	drivers/net/enic/
+F:	drivers/net/ethernet/cisco/enic/
 
 CIRRUS LOGIC EP93XX ETHERNET DRIVER
 M:	Hartley Sweeten <hsweeten@visionengravers.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 116f744..08ce280 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1457,12 +1457,6 @@ if NETDEV_10000
 config MDIO
 	tristate
 
-config ENIC
-	tristate "Cisco VIC Ethernet NIC Support"
-	depends on PCI && INET
-	help
-	  This enables the support for the Cisco VIC Ethernet card.
-
 config PASEMI_MAC
 	tristate "PA Semi 1/10Gbit MAC"
 	depends on PPC_PASEMI && PCI && INET
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 54146ed..cf1d5a2 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -20,7 +20,6 @@ obj-$(CONFIG_ATL1C) += atl1c/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
 obj-$(CONFIG_PTP_1588_CLOCK_GIANFAR) += gianfar_ptp.o
 obj-$(CONFIG_TEHUTI) += tehuti.o
-obj-$(CONFIG_ENIC) += enic/
 obj-$(CONFIG_JME) += jme.o
 obj-$(CONFIG_VMXNET3) += vmxnet3/
 
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index f23f1b2..18b634e 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -17,6 +17,7 @@ source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
+source "drivers/net/ethernet/cisco/Kconfig"
 source "drivers/net/ethernet/emulex/Kconfig"
 source "drivers/net/ethernet/neterion/Kconfig"
 source "drivers/net/ethernet/ibm/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 27e4da6..288179b 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -8,6 +8,7 @@ obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
+obj-$(CONFIG_NET_VENDOR_CISCO) += cisco/
 obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
 obj-$(CONFIG_NET_VENDOR_EXAR) += neterion/
 obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
diff --git a/drivers/net/ethernet/cisco/Kconfig b/drivers/net/ethernet/cisco/Kconfig
new file mode 100644
index 0000000..bbd5348
--- /dev/null
+++ b/drivers/net/ethernet/cisco/Kconfig
@@ -0,0 +1,22 @@
+#
+# Cisco device configuration
+#
+
+config NET_VENDOR_CISCO
+	bool "Cisco devices"
+	depends on PCI && INET
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Cisco cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if NET_VENDOR_CISCO
+
+source "drivers/net/ethernet/cisco/enic/Kconfig"
+
+endif # NET_VENDOR_CISCO
diff --git a/drivers/net/ethernet/cisco/Makefile b/drivers/net/ethernet/cisco/Makefile
new file mode 100644
index 0000000..6c7437b
--- /dev/null
+++ b/drivers/net/ethernet/cisco/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Cisco device drivers.
+#
+
+obj-$(CONFIG_ENIC) += enic/
diff --git a/drivers/net/ethernet/cisco/enic/Kconfig b/drivers/net/ethernet/cisco/enic/Kconfig
new file mode 100644
index 0000000..9cc706a
--- /dev/null
+++ b/drivers/net/ethernet/cisco/enic/Kconfig
@@ -0,0 +1,9 @@
+#
+# Cisco device configuration
+#
+
+config ENIC
+	tristate "Cisco VIC Ethernet NIC Support"
+	depends on PCI && INET
+	---help---
+	  This enables the support for the Cisco VIC Ethernet card.
diff --git a/drivers/net/enic/Makefile b/drivers/net/ethernet/cisco/enic/Makefile
similarity index 100%
rename from drivers/net/enic/Makefile
rename to drivers/net/ethernet/cisco/enic/Makefile
diff --git a/drivers/net/enic/cq_desc.h b/drivers/net/ethernet/cisco/enic/cq_desc.h
similarity index 100%
rename from drivers/net/enic/cq_desc.h
rename to drivers/net/ethernet/cisco/enic/cq_desc.h
diff --git a/drivers/net/enic/cq_enet_desc.h b/drivers/net/ethernet/cisco/enic/cq_enet_desc.h
similarity index 100%
rename from drivers/net/enic/cq_enet_desc.h
rename to drivers/net/ethernet/cisco/enic/cq_enet_desc.h
diff --git a/drivers/net/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
similarity index 100%
rename from drivers/net/enic/enic.h
rename to drivers/net/ethernet/cisco/enic/enic.h
diff --git a/drivers/net/enic/enic_dev.c b/drivers/net/ethernet/cisco/enic/enic_dev.c
similarity index 100%
rename from drivers/net/enic/enic_dev.c
rename to drivers/net/ethernet/cisco/enic/enic_dev.c
diff --git a/drivers/net/enic/enic_dev.h b/drivers/net/ethernet/cisco/enic/enic_dev.h
similarity index 100%
rename from drivers/net/enic/enic_dev.h
rename to drivers/net/ethernet/cisco/enic/enic_dev.h
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
similarity index 100%
rename from drivers/net/enic/enic_main.c
rename to drivers/net/ethernet/cisco/enic/enic_main.c
diff --git a/drivers/net/enic/enic_pp.c b/drivers/net/ethernet/cisco/enic/enic_pp.c
similarity index 100%
rename from drivers/net/enic/enic_pp.c
rename to drivers/net/ethernet/cisco/enic/enic_pp.c
diff --git a/drivers/net/enic/enic_pp.h b/drivers/net/ethernet/cisco/enic/enic_pp.h
similarity index 100%
rename from drivers/net/enic/enic_pp.h
rename to drivers/net/ethernet/cisco/enic/enic_pp.h
diff --git a/drivers/net/enic/enic_res.c b/drivers/net/ethernet/cisco/enic/enic_res.c
similarity index 100%
rename from drivers/net/enic/enic_res.c
rename to drivers/net/ethernet/cisco/enic/enic_res.c
diff --git a/drivers/net/enic/enic_res.h b/drivers/net/ethernet/cisco/enic/enic_res.h
similarity index 100%
rename from drivers/net/enic/enic_res.h
rename to drivers/net/ethernet/cisco/enic/enic_res.h
diff --git a/drivers/net/enic/rq_enet_desc.h b/drivers/net/ethernet/cisco/enic/rq_enet_desc.h
similarity index 100%
rename from drivers/net/enic/rq_enet_desc.h
rename to drivers/net/ethernet/cisco/enic/rq_enet_desc.h
diff --git a/drivers/net/enic/vnic_cq.c b/drivers/net/ethernet/cisco/enic/vnic_cq.c
similarity index 100%
rename from drivers/net/enic/vnic_cq.c
rename to drivers/net/ethernet/cisco/enic/vnic_cq.c
diff --git a/drivers/net/enic/vnic_cq.h b/drivers/net/ethernet/cisco/enic/vnic_cq.h
similarity index 100%
rename from drivers/net/enic/vnic_cq.h
rename to drivers/net/ethernet/cisco/enic/vnic_cq.h
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
similarity index 100%
rename from drivers/net/enic/vnic_dev.c
rename to drivers/net/ethernet/cisco/enic/vnic_dev.c
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/ethernet/cisco/enic/vnic_dev.h
similarity index 100%
rename from drivers/net/enic/vnic_dev.h
rename to drivers/net/ethernet/cisco/enic/vnic_dev.h
diff --git a/drivers/net/enic/vnic_devcmd.h b/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
similarity index 100%
rename from drivers/net/enic/vnic_devcmd.h
rename to drivers/net/ethernet/cisco/enic/vnic_devcmd.h
diff --git a/drivers/net/enic/vnic_enet.h b/drivers/net/ethernet/cisco/enic/vnic_enet.h
similarity index 100%
rename from drivers/net/enic/vnic_enet.h
rename to drivers/net/ethernet/cisco/enic/vnic_enet.h
diff --git a/drivers/net/enic/vnic_intr.c b/drivers/net/ethernet/cisco/enic/vnic_intr.c
similarity index 100%
rename from drivers/net/enic/vnic_intr.c
rename to drivers/net/ethernet/cisco/enic/vnic_intr.c
diff --git a/drivers/net/enic/vnic_intr.h b/drivers/net/ethernet/cisco/enic/vnic_intr.h
similarity index 100%
rename from drivers/net/enic/vnic_intr.h
rename to drivers/net/ethernet/cisco/enic/vnic_intr.h
diff --git a/drivers/net/enic/vnic_nic.h b/drivers/net/ethernet/cisco/enic/vnic_nic.h
similarity index 100%
rename from drivers/net/enic/vnic_nic.h
rename to drivers/net/ethernet/cisco/enic/vnic_nic.h
diff --git a/drivers/net/enic/vnic_resource.h b/drivers/net/ethernet/cisco/enic/vnic_resource.h
similarity index 100%
rename from drivers/net/enic/vnic_resource.h
rename to drivers/net/ethernet/cisco/enic/vnic_resource.h
diff --git a/drivers/net/enic/vnic_rq.c b/drivers/net/ethernet/cisco/enic/vnic_rq.c
similarity index 100%
rename from drivers/net/enic/vnic_rq.c
rename to drivers/net/ethernet/cisco/enic/vnic_rq.c
diff --git a/drivers/net/enic/vnic_rq.h b/drivers/net/ethernet/cisco/enic/vnic_rq.h
similarity index 100%
rename from drivers/net/enic/vnic_rq.h
rename to drivers/net/ethernet/cisco/enic/vnic_rq.h
diff --git a/drivers/net/enic/vnic_rss.h b/drivers/net/ethernet/cisco/enic/vnic_rss.h
similarity index 100%
rename from drivers/net/enic/vnic_rss.h
rename to drivers/net/ethernet/cisco/enic/vnic_rss.h
diff --git a/drivers/net/enic/vnic_stats.h b/drivers/net/ethernet/cisco/enic/vnic_stats.h
similarity index 100%
rename from drivers/net/enic/vnic_stats.h
rename to drivers/net/ethernet/cisco/enic/vnic_stats.h
diff --git a/drivers/net/enic/vnic_vic.c b/drivers/net/ethernet/cisco/enic/vnic_vic.c
similarity index 100%
rename from drivers/net/enic/vnic_vic.c
rename to drivers/net/ethernet/cisco/enic/vnic_vic.c
diff --git a/drivers/net/enic/vnic_vic.h b/drivers/net/ethernet/cisco/enic/vnic_vic.h
similarity index 100%
rename from drivers/net/enic/vnic_vic.h
rename to drivers/net/ethernet/cisco/enic/vnic_vic.h
diff --git a/drivers/net/enic/vnic_wq.c b/drivers/net/ethernet/cisco/enic/vnic_wq.c
similarity index 100%
rename from drivers/net/enic/vnic_wq.c
rename to drivers/net/ethernet/cisco/enic/vnic_wq.c
diff --git a/drivers/net/enic/vnic_wq.h b/drivers/net/ethernet/cisco/enic/vnic_wq.h
similarity index 100%
rename from drivers/net/enic/vnic_wq.h
rename to drivers/net/ethernet/cisco/enic/vnic_wq.h
diff --git a/drivers/net/enic/wq_enet_desc.h b/drivers/net/ethernet/cisco/enic/wq_enet_desc.h
similarity index 100%
rename from drivers/net/enic/wq_enet_desc.h
rename to drivers/net/ethernet/cisco/enic/wq_enet_desc.h
-- 
1.7.6

