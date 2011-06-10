From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH net-next] net: fix MIPS fallout from "net: remove interrupt.h
 inclusion from netdevice.h"
Date: Fri, 10 Jun 2011 16:36:43 +0300
Message-ID: <20110610133642.GA7451@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:56108 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756444Ab1FJNgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 09:36:48 -0400
Received: by bwz15 with SMTP id 15so2188110bwz.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 06:36:47 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/bcm63xx_enet.c       |    1 +
 drivers/net/cpmac.c              |    1 +
 drivers/net/mipsnet.c            |    1 +
 drivers/net/octeon/octeon_mgmt.c |    1 +
 4 files changed, 4 insertions(+)

--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -18,6 +18,7 @@
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/clk.h>
 #include <linux/etherdevice.h>
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -18,6 +18,7 @@
 
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/moduleparam.h>
 
 #include <linux/sched.h>
--- a/drivers/net/mipsnet.c
+++ b/drivers/net/mipsnet.c
@@ -5,6 +5,7 @@
  */
 
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/io.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -9,6 +9,7 @@
 #include <linux/capability.h>
 #include <linux/dma-mapping.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/platform_device.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
