From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH next 2/7] 8139cp : removal of headers.
Date: Fri, 30 Sep 2011 12:37:19 +0200
Message-ID: <20110930103719.GC26727@electric-eye.fr.zoreil.com>
References: <20110930103604.GA26727@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54227 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754105Ab1I3Kiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 06:38:52 -0400
Content-Disposition: inline
In-Reply-To: <20110930103604.GA26727@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/8139cp.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index c77d5af..60c8de5 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -55,8 +55,6 @@
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
-#include <linux/kernel.h>
-#include <linux/compiler.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/init.h>
@@ -65,7 +63,6 @@
 #include <linux/dma-mapping.h>
 #include <linux/delay.h>
 #include <linux/ethtool.h>
-#include <linux/gfp.h>
 #include <linux/mii.h>
 #include <linux/if_vlan.h>
 #include <linux/crc32.h>
@@ -73,10 +70,8 @@
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
-#include <linux/cache.h>
 #include <asm/io.h>
 #include <asm/irq.h>
-#include <asm/uaccess.h>
 
 /* These identify the driver base version and may not be removed. */
 static char version[] =
-- 
1.7.6.2
