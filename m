From: Faisal Latif <faisal.latif@intel.com>
Subject: [PATCH v3 15/16] i40iw: Kconfig and Makefile for iwarp module
Date: Wed, 20 Jan 2016 13:40:15 -0600
Message-ID: <1453318816-21672-16-git-send-email-faisal.latif@intel.com>
References: <1453318816-21672-1-git-send-email-faisal.latif@intel.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, e1000-rdma@lists.sourceforge.net,
	Faisal Latif <faisal.latif@intel.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5108 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964976AbcATTpn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2016 14:45:43 -0500
In-Reply-To: <1453318816-21672-1-git-send-email-faisal.latif@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kconfig and Makefile needed to build iwarp module.

Changes since v2:
	moved from Kbuild to Makefile

Signed-off-by: Faisal Latif <faisal.latif@intel.com>
---
 drivers/infiniband/hw/i40iw/Kconfig  | 7 +++++++
 drivers/infiniband/hw/i40iw/Makefile | 9 +++++++++
 2 files changed, 16 insertions(+)
 create mode 100644 drivers/infiniband/hw/i40iw/Kconfig
 create mode 100644 drivers/infiniband/hw/i40iw/Makefile

diff --git a/drivers/infiniband/hw/i40iw/Kconfig b/drivers/infiniband/hw/i40iw/Kconfig
new file mode 100644
index 0000000..6e7d27a
--- /dev/null
+++ b/drivers/infiniband/hw/i40iw/Kconfig
@@ -0,0 +1,7 @@
+config INFINIBAND_I40IW
+	tristate "Intel(R) Ethernet X722 iWARP Driver"
+	depends on INET && I40E
+	select GENERIC_ALLOCATOR
+	---help---
+	Intel(R) Ethernet X722 iWARP Driver
+	INET && I40IW && INFINIBAND && I40E
diff --git a/drivers/infiniband/hw/i40iw/Makefile b/drivers/infiniband/hw/i40iw/Makefile
new file mode 100644
index 0000000..90068c0
--- /dev/null
+++ b/drivers/infiniband/hw/i40iw/Makefile
@@ -0,0 +1,9 @@
+ccflags-y :=  -Idrivers/net/ethernet/intel/i40e
+
+obj-$(CONFIG_INFINIBAND_I40IW) += i40iw.o
+
+i40iw-objs :=\
+               i40iw_cm.o i40iw_ctrl.o \
+               i40iw_hmc.o i40iw_hw.o i40iw_main.o  \
+               i40iw_pble.o i40iw_puda.o i40iw_uk.o i40iw_utils.o \
+               i40iw_verbs.o i40iw_virtchnl.o i40iw_vf.o
-- 
2.5.3
