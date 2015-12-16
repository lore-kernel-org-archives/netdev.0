From: Faisal Latif <faisal.latif@intel.com>
Subject: [PATCH 15/15] i40iw: changes for build of i40iw module
Date: Wed, 16 Dec 2015 13:58:39 -0600
Message-ID: <1450295919-17292-16-git-send-email-faisal.latif@intel.com>
References: <1450295919-17292-1-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-2-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-3-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-4-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-5-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-6-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-7-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-8-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-9-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-10-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-11-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-12-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-13-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-14-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-15-git-send-email-faisal.latif@intel.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, e1000-rdma@lists.sourceforge.net,
	faisal.latif@intel.com
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64830 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755279AbbLPT7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 14:59:55 -0500
In-Reply-To: <1450295919-17292-15-git-send-email-faisal.latif@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IAINTAINERS< Kconfig, Makefile and rdma_netlink.h to include
i40iw

Signed-off-by: Faisal Latif <faisal.latif@intel.com>
---
 MAINTAINERS                      | 10 ++++++++++
 drivers/infiniband/Kconfig       |  1 +
 drivers/infiniband/hw/Makefile   |  1 +
 include/uapi/rdma/rdma_netlink.h |  1 +
 4 files changed, 13 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 69c8a9c..fc0ee30 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5600,6 +5600,16 @@ F:	Documentation/networking/i40evf.txt
 F:	drivers/net/ethernet/intel/
 F:	drivers/net/ethernet/intel/*/
 
+INTEL RDMA RNIC DRIVER
+M:	Faisal Latif <faisal.latif@intel.com>
+R:	Chien Tin Tung <chien.tin.tung@intel.com>
+R:	Mustafa Ismail <mustafa.ismail@intel.com>
+R:	Shiraz Saleem <shiraz.saleem@intel.com>
+R:	Tatyana Nikolova <tatyana.e.nikolova@intel.com>
+L:	linux-rdma@vger.kernel.org
+S:	Supported
+F:	drivers/infiniband/hw/i40iw/
+
 INTEL-MID GPIO DRIVER
 M:	David Cohen <david.a.cohen@linux.intel.com>
 L:	linux-gpio@vger.kernel.org
diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index aa26f3c..7ddd81f 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -58,6 +58,7 @@ source "drivers/infiniband/hw/mthca/Kconfig"
 source "drivers/infiniband/hw/qib/Kconfig"
 source "drivers/infiniband/hw/cxgb3/Kconfig"
 source "drivers/infiniband/hw/cxgb4/Kconfig"
+source "drivers/infiniband/hw/i40iw/Kconfig"
 source "drivers/infiniband/hw/mlx4/Kconfig"
 source "drivers/infiniband/hw/mlx5/Kconfig"
 source "drivers/infiniband/hw/nes/Kconfig"
diff --git a/drivers/infiniband/hw/Makefile b/drivers/infiniband/hw/Makefile
index aded2a5..c7ad0a4 100644
--- a/drivers/infiniband/hw/Makefile
+++ b/drivers/infiniband/hw/Makefile
@@ -2,6 +2,7 @@ obj-$(CONFIG_INFINIBAND_MTHCA)		+= mthca/
 obj-$(CONFIG_INFINIBAND_QIB)		+= qib/
 obj-$(CONFIG_INFINIBAND_CXGB3)		+= cxgb3/
 obj-$(CONFIG_INFINIBAND_CXGB4)		+= cxgb4/
+obj-$(CONFIG_INFINIBAND_I40IW)		+= i40iw/
 obj-$(CONFIG_MLX4_INFINIBAND)		+= mlx4/
 obj-$(CONFIG_MLX5_INFINIBAND)		+= mlx5/
 obj-$(CONFIG_INFINIBAND_NES)		+= nes/
diff --git a/include/uapi/rdma/rdma_netlink.h b/include/uapi/rdma/rdma_netlink.h
index c19a5dc..56bafbe 100644
--- a/include/uapi/rdma/rdma_netlink.h
+++ b/include/uapi/rdma/rdma_netlink.h
@@ -5,6 +5,7 @@
 
 enum {
 	RDMA_NL_RDMA_CM = 1,
+	RDMA_NL_I40IW,
 	RDMA_NL_NES,
 	RDMA_NL_C4IW,
 	RDMA_NL_LS,	/* RDMA Local Services */
-- 
2.5.3
