From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 6/6] [RFC] qlge: New Driver: Adding makefile.
Date: Fri, 22 Aug 2008 13:21:06 -0700
Message-ID: <12194364661220-git-send-email-ron.mercer@qlogic.com>
References: <20080822200906.GD2551@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, Ron Mercer <ron.mercer@qlogic.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:39657 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518AbYHVUVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 16:21:42 -0400
In-Reply-To: <20080822200906.GD2551@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/Makefile |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/qlge/Makefile

diff --git a/drivers/net/qlge/Makefile b/drivers/net/qlge/Makefile
new file mode 100644
index 0000000..09ebcdc
--- /dev/null
+++ b/drivers/net/qlge/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the Qlogic 10GbE PCI Express ethernet driver
+#
+
+obj-$(CONFIG_QLGE) += qlge.o
+
+qlge-objs := qlge_main.o qlge_dbg.o	qlge_mpi.o
-- 
1.5.0.rc4.16.g9e258

