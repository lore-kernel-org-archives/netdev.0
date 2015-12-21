From: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V1 14/16] i40iw: Kconfig and Kbuild for iwarp module
Date: Mon, 21 Dec 2015 17:13:14 -0600
Message-ID: <1450739596-23276-15-git-send-email-faisal.latif@intel.com>
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
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1450739596-23276-14-git-send-email-faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Kconfig and Kbuild needed to build iwarp module.

Signed-off-by: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/hw/i40iw/Kbuild  | 43 +++++++++++++++++++++++++++++++++++++
 drivers/infiniband/hw/i40iw/Kconfig |  7 ++++++
 2 files changed, 50 insertions(+)
 create mode 100644 drivers/infiniband/hw/i40iw/Kbuild
 create mode 100644 drivers/infiniband/hw/i40iw/Kconfig

diff --git a/drivers/infiniband/hw/i40iw/Kbuild b/drivers/infiniband/hw/i40iw/Kbuild
new file mode 100644
index 0000000..ba84a78
--- /dev/null
+++ b/drivers/infiniband/hw/i40iw/Kbuild
@@ -0,0 +1,43 @@
+################################################################################
+#
+# * Copyright (c) 2015 Intel Corporation.  All rights reserved.
+# *
+# * This software is available to you under a choice of one of two
+# * licenses.  You may choose to be licensed under the terms of the GNU
+# * General Public License (GPL) Version 2, available from the file
+# * COPYING in the main directory of this source tree, or the
+# * OpenFabrics.org BSD license below:
+# *
+# *   Redistribution and use in source and binary forms, with or
+# *   without modification, are permitted provided that the following
+# *   conditions are met:
+# *
+# *    - Redistributions of source code must retain the above
+# *	copyright notice, this list of conditions and the following
+# *	disclaimer.
+# *
+# *    - Redistributions in binary form must reproduce the above
+# *	copyright notice, this list of conditions and the following
+# *	disclaimer in the documentation and/or other materials
+# *	provided with the distribution.
+# *
+# * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+# * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+# * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+# * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+# * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+# * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+# * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+# * SOFTWARE.
+#
+################################################################################
+
+ccflags-y :=  -Idrivers/net/ethernet/intel/i40e
+
+obj-m += i40iw.o
+
+i40iw-objs :=\
+               i40iw_cm.o i40iw_ctrl.o \
+               i40iw_hmc.o i40iw_hw.o i40iw_main.o  \
+               i40iw_pble.o i40iw_puda.o i40iw_uk.o i40iw_utils.o \
+               i40iw_verbs.o i40iw_virtchnl.o i40iw_vf.o
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
-- 
2.5.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
