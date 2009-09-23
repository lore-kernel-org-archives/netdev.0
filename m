From: sjur.brandeland@stericsson.com
Subject: [PATCH 8/8] [RFC] CAIF Protocol Stack
Date: Wed, 23 Sep 2009 19:31:42 +0200
Message-ID: <1253727103-10443-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: Kim.xx.Lilliestierna@ericsson.com, sjur.brandeland@stericsson.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:55556 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753244AbZIWSbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 14:31:45 -0400
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KQF003SSQ0WF560@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 23 Sep 2009 19:31:44 +0200 (CEST)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KQF004IAQ0WNGG0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 23 Sep 2009 19:31:44 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kim Lilliestierna <Kim.xx.Lilliestierna@ericsson.com>

Signed-off-by: sjur.brandeland@stericsson.com

---
 drivers/net/Makefile |    1 +
 net/Kconfig          |    1 +
 net/Makefile         |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 7629c90..d8441a8 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -255,4 +255,5 @@ obj-$(CONFIG_NETXEN_NIC) += netxen/
 obj-$(CONFIG_NIU) += niu.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_SFC) += sfc/
+obj-$(CONFIG_CAIF) += caif/
 
diff --git a/net/Kconfig b/net/Kconfig
index 0210002..51e3eaa 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -253,5 +253,6 @@ endmenu
 
 source "net/rfkill/Kconfig"
 source "net/9p/Kconfig"
+source "net/caif/Kconfig"
 
 endif   # if NET

diff --git a/net/Makefile b/net/Makefile
index ba324ae..449dd91 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -57,6 +57,7 @@ obj-$(CONFIG_NETLABEL)		+= netlabel/
 obj-$(CONFIG_IUCV)		+= iucv/
 obj-$(CONFIG_RFKILL)		+= rfkill/
 obj-$(CONFIG_NET_9P)		+= 9p/
+obj-$(CONFIG_CAIF)		+= caif/
 ifneq ($(CONFIG_DCB),)
 obj-y				+= dcb/
 endif
-- 
1.6.0.4

