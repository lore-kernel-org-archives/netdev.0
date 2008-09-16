From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 02/14] Phonet: add CONFIG_PHONET
Date: Tue, 16 Sep 2008 18:08:02 +0300
Message-ID: <1221577694-4513-2-git-send-email-remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:47054 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754373AbYIPPJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 11:09:27 -0400
Received: from esebh107.NOE.Nokia.com (esebh107.ntc.nokia.com [172.21.143.143])
	by mgw-mx09.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8GF9CCX013079
	for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 10:09:26 -0500
In-Reply-To: <200809161757.38571.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/Kconfig  |   11 +++++++++++
 net/phonet/Makefile |    3 +++
 2 files changed, 14 insertions(+), 0 deletions(-)
 create mode 100644 net/phonet/Kconfig
 create mode 100644 net/phonet/Makefile

diff --git a/net/phonet/Kconfig b/net/phonet/Kconfig
new file mode 100644
index 0000000..02f8921
--- /dev/null
+++ b/net/phonet/Kconfig
@@ -0,0 +1,11 @@
+#
+# Phonet protocol
+#
+
+config PHONET
+	tristate "Phonet protocols family"
+	help
+	  Phonet is a communication protocol used by Nokia modems.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called phonet. If unsure, say N.
diff --git a/net/phonet/Makefile b/net/phonet/Makefile
new file mode 100644
index 0000000..4ced746
--- /dev/null
+++ b/net/phonet/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_PHONET) += phonet.o
+
+phonet-objs :=
-- 
1.5.4.3

