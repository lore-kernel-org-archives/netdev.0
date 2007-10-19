From: ggrundstrom@neteffect.com
Subject: [ofa-general] [PATCH 13/14 v2] nes: kernel build infrastructure
Date: Fri, 19 Oct 2007 15:27:01 -0500
Message-ID: <200710192027.l9JKR197021855@neteffect.com>
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: ewg@lists.openfabrics.org, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Kconfig kernel build file.

Signed-off-by: Glenn Grundstrom <ggrundstrom@neteffect.com>
---

--- NULL	1969-12-31 18:00:00.000000000 -0600
+++ ofa_kernel-1.3/drivers/infiniband/hw/nes/Kconfig	2007-10-19 09:43:32.000000000 -0500
@@ -0,0 +1,15 @@
+config INFINIBAND_NES
+	tristate "NetEffect RNIC Driver"
+	depends on PCI && INET && INFINIBAND
+	---help---
+	  This is a low-level driver for NetEffect RDMA enabled
+	  Network Interface Cards (RNIC).
+
+config INFINIBAND_NES_DEBUG
+	bool "Verbose debugging output"
+	depends on INFINIBAND_NES
+	default n
+	---help---
+	  This option causes the NetEffect RNIC driver to produce debug
+	  messages.  Select this if you are developing the driver
+	  or trying to diagnose a problem.
