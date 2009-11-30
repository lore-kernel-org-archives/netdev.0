From: sjur.brandeland@stericsson.com
Subject: [RFC PATCH v3  8/8] CAIF Protocol Stack
Date: Mon, 30 Nov 2009 16:00:52 +0100
Message-ID: <1259593252-2493-9-git-send-email-sjur.brandeland@stericsson.com>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-3-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-4-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-5-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-6-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-7-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-8-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: randy.dunlap@oracle.com, kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, stefano.babic@babic.homelinux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:55205 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbZK3QB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 11:01:56 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KTX0018EGF7KF20@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Mon, 30 Nov 2009 16:01:55 +0100 (CET)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KTX00IAMGDW9QV1@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Mon, 30 Nov 2009 16:01:55 +0100 (CET)
In-reply-to: <1259593252-2493-8-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 drivers/net/Makefile |    1 +
 net/Kconfig          |    1 +
 net/Makefile         |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 246323d..17796f9 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -285,3 +285,4 @@ obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_SFC) += sfc/
 
 obj-$(CONFIG_WIMAX) += wimax/
+obj-$(CONFIG_CAIF) += caif/
diff --git a/net/Kconfig b/net/Kconfig
index 041c35e..1c3890f 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -275,5 +275,6 @@ source "net/wimax/Kconfig"
 
 source "net/rfkill/Kconfig"
 source "net/9p/Kconfig"
+source "net/caif/Kconfig"
 
 endif   # if NET
diff --git a/net/Makefile b/net/Makefile
index 1542e72..a5eae27 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -56,6 +56,7 @@ obj-$(CONFIG_NETLABEL)		+= netlabel/
 obj-$(CONFIG_IUCV)		+= iucv/
 obj-$(CONFIG_RFKILL)		+= rfkill/
 obj-$(CONFIG_NET_9P)		+= 9p/
+obj-$(CONFIG_CAIF)		+= caif/
 ifneq ($(CONFIG_DCB),)
 obj-y				+= dcb/
 endif
-- 
1.6.2.2.1669.g7eaf8

