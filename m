From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [NET] removed unused #include <version.h>
Date: Sun, 17 Aug 2008 07:51:20 +0800
Message-ID: <20080817072712.1632.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com, jgarzik@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.187]:14173 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754805AbYHPXvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2008 19:51:32 -0400
Received: by ti-out-0910.google.com with SMTP id b6so623856tic.23
        for <netdev@vger.kernel.org>; Sat, 16 Aug 2008 16:51:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The drivers below do not use LINUX_VERSION_CODE nor KERNEL_VERSION.
  drivers/net/myri10ge/myri10ge.c
  drivers/net/netxen/netxen_nic_ethtool.c
  drivers/net/tokenring/lanstreamer.c

This patch removes the said #include <version.h>.

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index f1de38f..f88e290 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -56,7 +56,6 @@
 #include <linux/ethtool.h>
 #include <linux/firmware.h>
 #include <linux/delay.h>
-#include <linux/version.h>
 #include <linux/timer.h>
 #include <linux/vmalloc.h>
 #include <linux/crc32.h>
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 4ad3e08..b974ca0 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -38,7 +38,6 @@
 #include <asm/io.h>
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
-#include <linux/version.h>
 
 #include "netxen_nic.h"
 #include "netxen_nic_hw.h"
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index 47d84cd..59d1673 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -119,7 +119,6 @@
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
 #include <linux/spinlock.h>
-#include <linux/version.h>
 #include <linux/bitops.h>
 #include <linux/jiffies.h>
 

