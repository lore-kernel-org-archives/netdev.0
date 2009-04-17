From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH -next 2/2] irda: include etherdevice.h for eth_*() functions
Date: Fri, 17 Apr 2009 05:23:03 +0400
Message-ID: <1239931383-30525-2-git-send-email-a.beregalov@gmail.com>
References: <1239931383-30525-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:34231 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757497AbZDQBXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 21:23:09 -0400
Received: by fg-out-1718.google.com with SMTP id e12so223621fga.17
        for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 18:23:07 -0700 (PDT)
In-Reply-To: <1239931383-30525-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/irda/au1k_ir.c    |    1 +
 drivers/net/irda/pxaficp_ir.c |    1 +
 drivers/net/irda/sa1100_ir.c  |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index 204def0..269153e 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -23,6 +23,7 @@
 #include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/slab.h>
 #include <linux/rtnetlink.h>
 #include <linux/interrupt.h>
diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index e8ced56..3376a4f 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -14,6 +14,7 @@
  */
 #include <linux/module.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/platform_device.h>
 #include <linux/clk.h>
 
diff --git a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
index 44a748e..4ed7636 100644
--- a/drivers/net/irda/sa1100_ir.c
+++ b/drivers/net/irda/sa1100_ir.c
@@ -24,6 +24,7 @@
 #include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/slab.h>
 #include <linux/rtnetlink.h>
 #include <linux/interrupt.h>
-- 
1.6.2.3

