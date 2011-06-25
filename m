From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 48/72] octeon: Move the Cavium driver
Date: Sat, 25 Jun 2011 06:58:59 -0700
Message-ID: <1309010363-22750-49-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	David Daney <ddaney@caviumnetworks.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:41778 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752128Ab1FYOAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:16 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Cavium driver to drivers/net/ethernet/octeon/ and
make the necessary Kconfig and Makefile changes.

CC: David Daney <ddaney@caviumnetworks.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                             |    2 --
 drivers/net/Makefile                            |    1 -
 drivers/net/ethernet/Kconfig                    |    1 +
 drivers/net/ethernet/Makefile                   |    1 +
 drivers/net/{ => ethernet}/octeon/Kconfig       |    0
 drivers/net/{ => ethernet}/octeon/Makefile      |    0
 drivers/net/{ => ethernet}/octeon/octeon_mgmt.c |    0
 7 files changed, 2 insertions(+), 3 deletions(-)
 rename drivers/net/{ => ethernet}/octeon/Kconfig (100%)
 rename drivers/net/{ => ethernet}/octeon/Makefile (100%)
 rename drivers/net/{ => ethernet}/octeon/octeon_mgmt.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index fb16747..f4708d4 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -589,8 +589,6 @@ config LANTIQ_ETOP
 	help
 	  Support for the MII0 inside the Lantiq SoC
 
-source "drivers/net/octeon/Kconfig"
-
 endif # NET_ETHERNET
 
 #
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index f473c26..a53f0b3 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -115,5 +115,4 @@ obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_WIMAX) += wimax/
 obj-$(CONFIG_CAIF) += caif/
 
-obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
 obj-$(CONFIG_TILE_NET) += tile/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index cf3da85..7e83747 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -57,6 +57,7 @@ source "drivers/net/ethernet/motorola/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
 source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
+source "drivers/net/ethernet/octeon/Kconfig"
 source "drivers/net/ethernet/isa/Kconfig"
 source "drivers/net/ethernet/oki/Kconfig"
 source "drivers/net/ethernet/packetengines/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 0c6c7a5..b2f51c5 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -27,6 +27,7 @@ obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
 obj-$(CONFIG_NET_VENDOR_MOTOROLA) += motorola/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
+obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
 obj-$(CONFIG_NET_ISA) += isa/
 obj-$(CONFIG_NET_PACKET_ENGINE) += packetengines/
 obj-$(CONFIG_NET_VENDOR_OKI) += oki/
diff --git a/drivers/net/octeon/Kconfig b/drivers/net/ethernet/octeon/Kconfig
similarity index 100%
rename from drivers/net/octeon/Kconfig
rename to drivers/net/ethernet/octeon/Kconfig
diff --git a/drivers/net/octeon/Makefile b/drivers/net/ethernet/octeon/Makefile
similarity index 100%
rename from drivers/net/octeon/Makefile
rename to drivers/net/ethernet/octeon/Makefile
diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
similarity index 100%
rename from drivers/net/octeon/octeon_mgmt.c
rename to drivers/net/ethernet/octeon/octeon_mgmt.c
-- 
1.7.5.4

