From: ggrundstrom@neteffect.com
Subject: [ofa-general] [PATCH 14/14 v2] nes: kernel build infrastructure
Date: Fri, 19 Oct 2007 15:28:49 -0500
Message-ID: <200710192028.l9JKSnZG021867@neteffect.com>
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

Makefile kernel build file.

Signed-off-by: Glenn Grundstrom <ggrundstrom@neteffect.com>
---

--- NULL	1969-12-31 18:00:00.000000000 -0600
+++ ofa_kernel-1.3/drivers/infiniband/hw/nes/Makefile	2007-10-19 09:43:32.000000000 -0500
@@ -0,0 +1,7 @@
+
+EXTRA_CFLAGS += -DNES_MINICM
+
+obj-$(CONFIG_INFINIBAND_NES) += iw_nes.o
+
+iw_nes-objs := nes.o nes_hw.o nes_nic.o nes_utils.o nes_verbs.o nes_cm.o
+
