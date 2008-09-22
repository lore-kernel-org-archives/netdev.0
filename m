From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 03/11] Phonet: add CONFIG_PHONET
Date: Mon, 22 Sep 2008 18:47:17 +0300
Message-ID: <1222098445-26175-3-git-send-email-remi.denis-courmont@nokia.com>
References: <200809221845.54736.remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:52998 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbYIVPrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 11:47:42 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8MFlZFV027641
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 18:47:40 +0300
In-Reply-To: <200809221845.54736.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/Kconfig         |    1 +
 net/Makefile        |    1 +
 net/phonet/Kconfig  |   16 ++++++++++++++++
 net/phonet/Makefile |    4 ++++
 4 files changed, 22 insertions(+), 0 deletions(-)
 create mode 100644 net/phonet/Kconfig
 create mode 100644 net/phonet/Makefile

diff --git a/net/Kconfig b/net/Kconfig
index d87de48..9103a16 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -232,6 +232,7 @@ source "net/can/Kconfig"
 source "net/irda/Kconfig"
 source "net/bluetooth/Kconfig"
 source "net/rxrpc/Kconfig"
+source "net/phonet/Kconfig"
 
 config FIB_RULES
 	bool
diff --git a/net/Makefile b/net/Makefile
index 4f43e7f..acaf819 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -42,6 +42,7 @@ obj-$(CONFIG_AF_RXRPC)		+= rxrpc/
 obj-$(CONFIG_ATM)		+= atm/
 obj-$(CONFIG_DECNET)		+= decnet/
 obj-$(CONFIG_ECONET)		+= econet/
+obj-$(CONFIG_PHONET)		+= phonet/
 ifneq ($(CONFIG_VLAN_8021Q),)
 obj-y				+= 8021q/
 endif
diff --git a/net/phonet/Kconfig b/net/phonet/Kconfig
new file mode 100644
index 0000000..51a5669
--- /dev/null
+++ b/net/phonet/Kconfig
@@ -0,0 +1,16 @@
+#
+# Phonet protocol
+#
+
+config PHONET
+	tristate "Phonet protocols family"
+	help
+	  The Phone Network protocol (PhoNet) is a packet-oriented
+	  communication protocol developped by Nokia for use with its modems.
+
+	  This is required for Maemo to use cellular data connectivity (if
+	  supported). It can also be used to control Nokia phones
+	  from a Linux computer, although AT commands may be easier to use.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called phonet. If unsure, say N.
diff --git a/net/phonet/Makefile b/net/phonet/Makefile
new file mode 100644
index 0000000..5dbff68
--- /dev/null
+++ b/net/phonet/Makefile
@@ -0,0 +1,4 @@
+obj-$(CONFIG_PHONET) += phonet.o
+
+phonet-objs := \
+	af_phonet.o
-- 
1.5.4.3

