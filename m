From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 8/8] gigaset: move up Kconfig inclusion point
Date: Thu, 14 May 2009 00:44:18 +0200 (CEST)
Message-ID: <20090514-patch-08.tilman@imap.cc>
References: <20090514-patch-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:38983 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760417AbZEMWog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 18:44:36 -0400
In-Reply-To: <20090514-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for porting to kernel CAPI subsystem, include the
Gigaset driver's Kconfig directly from ISDN's instead of I4L's.

Impact: Kconfig reorganisation, no functional change
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/Kconfig         |    2 ++
 drivers/isdn/gigaset/Kconfig |    1 +
 drivers/isdn/i4l/Kconfig     |    2 --
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/Kconfig b/drivers/isdn/Kconfig
index 3d113c6..02bdca6 100644
--- a/drivers/isdn/Kconfig
+++ b/drivers/isdn/Kconfig
@@ -61,4 +61,6 @@ source "drivers/isdn/hardware/Kconfig"
 
 endif # ISDN_CAPI
 
+source "drivers/isdn/gigaset/Kconfig"
+
 endif # ISDN
diff --git a/drivers/isdn/gigaset/Kconfig b/drivers/isdn/gigaset/Kconfig
index 65ca305..18ab865 100644
--- a/drivers/isdn/gigaset/Kconfig
+++ b/drivers/isdn/gigaset/Kconfig
@@ -1,5 +1,6 @@
 menuconfig ISDN_DRV_GIGASET
 	tristate "Siemens Gigaset support"
+	depends on ISDN_I4L
 	select CRC_CCITT
 	select BITREVERSE
 	help
diff --git a/drivers/isdn/i4l/Kconfig b/drivers/isdn/i4l/Kconfig
index 36778b2..ed3510f 100644
--- a/drivers/isdn/i4l/Kconfig
+++ b/drivers/isdn/i4l/Kconfig
@@ -135,5 +135,3 @@ source "drivers/isdn/act2000/Kconfig"
 source "drivers/isdn/hysdn/Kconfig"
 
 endmenu
-
-source "drivers/isdn/gigaset/Kconfig"
-- 
1.6.2.1.214.ge986c

