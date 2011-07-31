From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 48/71] octeon: Move the Cavium driver
Date: Sat, 30 Jul 2011 20:27:07 -0700
Message-ID: <1312082850-24914-49-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	David Daney <ddaney@caviumnetworks.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2242 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753359Ab1GaD2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:23 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index eb50af7..2ad05a8 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -506,8 +506,6 @@ config LANTIQ_ETOP
 	help
 	  Support for the MII0 inside the Lantiq SoC
 
-source "drivers/net/octeon/Kconfig"
-
 endif # NET_ETHERNET
 
 #
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index d8c286e..648fa5c 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -105,5 +105,4 @@ obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_WIMAX) += wimax/
 obj-$(CONFIG_CAIF) += caif/
 
-obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
 obj-$(CONFIG_TILE_NET) += tile/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 140dd73..70c60ef 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -38,6 +38,7 @@ source "drivers/net/ethernet/myricom/Kconfig"
 source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
 source "drivers/net/ethernet/nuvoton/Kconfig"
+source "drivers/net/ethernet/octeon/Kconfig"
 source "drivers/net/ethernet/oki-semi/Kconfig"
 source "drivers/net/ethernet/packetengines/Kconfig"
 source "drivers/net/ethernet/pasemi/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 8a97b19..929ee29 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -29,6 +29,7 @@ obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
 obj-$(CONFIG_NET_VENDOR_NUVOTON) += nuvoton/
+obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
 obj-$(CONFIG_NET_VENDOR_OKI) += oki-semi/
 obj-$(CONFIG_NET_PACKET_ENGINE) += packetengines/
 obj-$(CONFIG_NET_VENDOR_PASEMI) += pasemi/
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
1.7.6

