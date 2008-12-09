From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH 11/11] benet: Kconfig, MAINTAINETS, drivers/net Makefile
Date: Tue, 09 Dec 2008 19:51:11 +0530
Message-ID: <1228832471.6435.104.camel@sperla-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jeff Garzik <jgarzik@pobox.com>, subbu <subbus@serverengines.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail96.messagelabs.com ([216.82.254.19]:56858 "EHLO
	mail96.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754591AbYLIOWk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 09:22:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/Kconfig           |    2 ++
 drivers/net/Makefile          |    1 +
 drivers/net/benet/Kconfig     |    7 +++++++
 drivers/net/benet/MAINTAINERS |    8 ++++++++
 4 files changed, 18 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/benet/Kconfig
 create mode 100644 drivers/net/benet/MAINTAINERS

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 231eeaf..85992af 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2579,6 +2579,8 @@ config QLGE
 
 source "drivers/net/sfc/Kconfig"
 
+source "drivers/net/benet/Kconfig"
+
 endif # NETDEV_10000
 
 source "drivers/net/tokenring/Kconfig"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 017383a..0d48432 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -21,6 +21,7 @@ obj-$(CONFIG_GIANFAR) += gianfar_driver.o
 obj-$(CONFIG_TEHUTI) += tehuti.o
 obj-$(CONFIG_ENIC) += enic/
 obj-$(CONFIG_JME) += jme.o
+obj-$(CONFIG_BENET) += benet/
 
 gianfar_driver-objs := gianfar.o \
 		gianfar_ethtool.o \
diff --git a/drivers/net/benet/Kconfig b/drivers/net/benet/Kconfig
new file mode 100644
index 0000000..f680607
--- /dev/null
+++ b/drivers/net/benet/Kconfig
@@ -0,0 +1,7 @@
+config BENET
+	tristate "ServerEngines 10Gb NIC - BladeEngine"
+	depends on PCI && INET
+	select INET_LRO
+	help
+	  This driver implements the NIC functionality for ServerEngines
+	  10Gb network adapter BladeEngine (EC 3210).
diff --git a/drivers/net/benet/MAINTAINERS b/drivers/net/benet/MAINTAINERS
new file mode 100644
index 0000000..60f3144
--- /dev/null
+++ b/drivers/net/benet/MAINTAINERS
@@ -0,0 +1,8 @@
+SERVER ENGINES 10Gbe NIC - BLADE-ENGINE
+P:	Subbu Seetharaman
+M:	subbus@serverengines.com
+P:	Sathya Perla	
+M:	sathyap@serverengines.com
+L:	netdev@vger.kernel.org
+W:	http://www.serverengines.com
+S:	Supported
-- 
1.5.5





___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

