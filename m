From: Faisal Latif <faisal.latif@intel.com>
Subject: [PATCH V1 16/16] i40iw: changes for build of i40iw module
Date: Mon, 21 Dec 2015 17:13:16 -0600
Message-ID: <1450739596-23276-17-git-send-email-faisal.latif@intel.com>
References: <1450739596-23276-1-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-2-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-3-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-4-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-5-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-6-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-7-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-8-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-9-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-10-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-11-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-12-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-13-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-14-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-15-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-16-git-send-email-faisal.latif@intel.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, e1000-rdma@lists.sourceforge.net,
	faisal.latif@intel.com
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:24842 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752754AbbLUXOK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Dec 2015 18:14:10 -0500
In-Reply-To: <1450739596-23276-16-git-send-email-faisal.latif@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MAINTAINERS, Kconfig, and Makefile to build i40iw module

Signed-off-by: Faisal Latif <faisal.latif@intel.com>
---
 MAINTAINERS                    | 10 ++++++++++
 drivers/infiniband/Kconfig     |  1 +
 drivers/infiniband/hw/Makefile |  1 +
 3 files changed, 12 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 9bff63c..fc85ad3 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5601,6 +5601,16 @@ F:	Documentation/networking/i40evf.txt
 F:	drivers/net/ethernet/intel/
 F:	drivers/net/ethernet/intel/*/
 
+INTEL RDMA RNIC DRIVER
+M:     Faisal Latif <faisal.latif@intel.com>
+R:     Chien Tin Tung <chien.tin.tung@intel.com>
+R:     Mustafa Ismail <mustafa.ismail@intel.com>
+R:     Shiraz Saleem <shiraz.saleem@intel.com>
+R:     Tatyana Nikolova <tatyana.e.nikolova@intel.com>
+L:     linux-rdma@vger.kernel.org
+S:     Supported
+F:     drivers/infiniband/hw/i40iw/
+
 INTEL-MID GPIO DRIVER
 M:	David Cohen <david.a.cohen@linux.intel.com>
 L:	linux-gpio@vger.kernel.org
diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index 282ec0b..cd8fa5c 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -59,6 +59,7 @@ source "drivers/infiniband/hw/mthca/Kconfig"
 source "drivers/infiniband/hw/qib/Kconfig"
 source "drivers/infiniband/hw/cxgb3/Kconfig"
 source "drivers/infiniband/hw/cxgb4/Kconfig"
+source "drivers/infiniband/hw/i40iw/Kconfig"
 source "drivers/infiniband/hw/mlx4/Kconfig"
 source "drivers/infiniband/hw/mlx5/Kconfig"
 source "drivers/infiniband/hw/nes/Kconfig"
diff --git a/drivers/infiniband/hw/Makefile b/drivers/infiniband/hw/Makefile
index aded2a5..8860057 100644
--- a/drivers/infiniband/hw/Makefile
+++ b/drivers/infiniband/hw/Makefile
@@ -2,6 +2,7 @@ obj-$(CONFIG_INFINIBAND_MTHCA)		+= mthca/
 obj-$(CONFIG_INFINIBAND_QIB)		+= qib/
 obj-$(CONFIG_INFINIBAND_CXGB3)		+= cxgb3/
 obj-$(CONFIG_INFINIBAND_CXGB4)		+= cxgb4/
+obj-$(CONFIG_INFINIBAND_I40IW)         += i40iw/
 obj-$(CONFIG_MLX4_INFINIBAND)		+= mlx4/
 obj-$(CONFIG_MLX5_INFINIBAND)		+= mlx5/
 obj-$(CONFIG_INFINIBAND_NES)		+= nes/
-- 
2.5.3
