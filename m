From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATCH 12/12] benet: Kconfig, Makefile, MAINTAINERS
Date: Thu, 12 Jun 2008 03:59:16 -0700
Message-ID: <20080612105916.ffa60aa0@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail96.messagelabs.com ([216.82.254.19]:60944 "EHLO
	mail96.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756793AbYFLK7T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 06:59:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
---
 MAINTAINERS          |    7 +++++++
 drivers/net/Kconfig  |    8 ++++++++
 drivers/net/Makefile |    1 +
 3 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 9d43042..156bf68 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3618,6 +3618,13 @@ L:	linux-ide@vger.kernel.org
 T:	git kernel.org:/pub/scm/linux/kernel/git/jgarzik/libata-dev.git
 S:	Supported
 
+SERVER ENGINES 10Gbe NIC - BLADE-ENGINE
+P:	Subbu Seetharaman
+M:	subbus@serverengines.com
+L:	netdev@vger.kernel.org
+W:	http://www.serverengines.com
+S:	Supported
+
 SGI SN-IA64 (Altix) SERIAL CONSOLE DRIVER
 P:	Pat Gefre
 M:	pfg@sgi.com
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f4182cf..78b4d6e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2581,6 +2581,14 @@ config BNX2X
 
 source "drivers/net/sfc/Kconfig"
 
+config BENET
+	tristate "ServerEngines 10Gb NIC - BladeEngine"
+	depends on PCI
+	select INET_LRO
+	help
+	  This driver implements the NIC functionality for ServerEngines
+	  10Gb network adapter BladeEngine (EC 3210).
+
 endif # NETDEV_10000
 
 source "drivers/net/tokenring/Kconfig"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index dcbfe84..8f3c1ff 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -18,6 +18,7 @@ obj-$(CONFIG_BONDING) += bonding/
 obj-$(CONFIG_ATL1) += atlx/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
 obj-$(CONFIG_TEHUTI) += tehuti.o
+obj-$(CONFIG_BENET) += benet/
 
 gianfar_driver-objs := gianfar.o \
 		gianfar_ethtool.o \
-- 
1.5.5



___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

