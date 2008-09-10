From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 3/8] [RFC] qlge: Added drivers/net/qlge/Makefile.
Date: Wed, 10 Sep 2008 13:58:57 -0700
Message-ID: <12210803421846-git-send-email-ron.mercer@qlogic.com>
References: <20080910205813.GA13266@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:29388 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359AbYIJU7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 16:59:48 -0400
In-Reply-To: <20080910205813.GA13266@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/Makefile |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/qlge/Makefile

diff --git a/drivers/net/qlge/Makefile b/drivers/net/qlge/Makefile
new file mode 100644
index 0000000..8a19765
--- /dev/null
+++ b/drivers/net/qlge/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the Qlogic 10GbE PCI Express ethernet driver
+#
+
+obj-$(CONFIG_QLGE) += qlge.o
+
+qlge-objs := qlge_main.o qlge_dbg.o qlge_mpi.o qlge_ethtool.o
-- 
1.5.0.rc4.16.g9e258

