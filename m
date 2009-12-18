From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH v2 05/12] ixgbevf: Driver Makefile
Date: Fri, 18 Dec 2009 14:52:16 -0800
Message-ID: <20091218225215.10698.7180.stgit@localhost.localdomain>
References: <20091218225043.10698.58897.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gospo@redhat.com, Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:46466
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755612AbZLRWwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 17:52:36 -0500
In-Reply-To: <20091218225043.10698.58897.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

82599 Virtual Function Device Driver Makefile

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/Makefile |   38 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 38 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ixgbevf/Makefile

diff --git a/drivers/net/ixgbevf/Makefile b/drivers/net/ixgbevf/Makefile
new file mode 100644
index 0000000..dd4e0d2
--- /dev/null
+++ b/drivers/net/ixgbevf/Makefile
@@ -0,0 +1,38 @@
+################################################################################
+#
+# Intel 82599 Virtual Function driver
+# Copyright(c) 1999 - 2009 Intel Corporation.
+#
+# This program is free software; you can redistribute it and/or modify it
+# under the terms and conditions of the GNU General Public License,
+# version 2, as published by the Free Software Foundation.
+#
+# This program is distributed in the hope it will be useful, but WITHOUT
+# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+# more details.
+#
+# You should have received a copy of the GNU General Public License along with
+# this program; if not, write to the Free Software Foundation, Inc.,
+# 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+#
+# The full GNU General Public License is included in this distribution in
+# the file called "COPYING".
+#
+# Contact Information:
+# e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+# Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+#
+################################################################################
+
+#
+# Makefile for the Intel(R) 82599 VF ethernet driver
+#
+
+obj-$(CONFIG_IXGBEVF) += ixgbevf.o
+
+ixgbevf-objs := vf.o \
+                mbx.o \
+                ethtool.o \
+                ixgbevf_main.o
+

