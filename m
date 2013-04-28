From: Tony Prisk <linux@prisktech.co.nz>
Subject: [PATCH 1/4] net: velocity: Alphabetize #includes
Date: Sun, 28 Apr 2013 15:16:43 +1200
Message-ID: <1367119006-31280-2-git-send-email-linux@prisktech.co.nz>
References: <1367119006-31280-1-git-send-email-linux@prisktech.co.nz>
Cc: netdev@vger.kernel.org,
	vt8500-wm8505-linux-kernel@googlegroups.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Tony Prisk <linux@prisktech.co.nz>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.prisktech.co.nz ([115.188.14.127]:60481 "EHLO
	server.prisktech.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754092Ab3D1DQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Apr 2013 23:16:49 -0400
In-Reply-To: <1367119006-31280-1-git-send-email-linux@prisktech.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to number of #includes, alphabetize them to help avoid duplicates.

Signed-off-by: Tony Prisk <linux@prisktech.co.nz>
---
 drivers/net/ethernet/via/via-velocity.c |   48 +++++++++++++++----------------
 1 file changed, 24 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 1bc7f9fd..eb2a023 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -42,40 +42,40 @@
  *
  */
 
-#include <linux/module.h>
-#include <linux/types.h>
 #include <linux/bitops.h>
-#include <linux/init.h>
-#include <linux/mm.h>
+#include <linux/crc-ccitt.h>
+#include <linux/crc32.h>
+#include <linux/delay.h>
 #include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/if.h>
+#include <linux/if_arp.h>
+#include <linux/if_vlan.h>
+#include <linux/in.h>
+#include <linux/inetdevice.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
 #include <linux/ioport.h>
-#include <linux/pci.h>
+#include <linux/ip.h>
 #include <linux/kernel.h>
+#include <linux/mii.h>
+#include <linux/mm.h>
+#include <linux/module.h>
 #include <linux/netdevice.h>
-#include <linux/etherdevice.h>
+#include <linux/pci.h>
+#include <linux/proc_fs.h>
+#include <linux/reboot.h>
 #include <linux/skbuff.h>
-#include <linux/delay.h>
-#include <linux/timer.h>
 #include <linux/slab.h>
-#include <linux/interrupt.h>
 #include <linux/string.h>
-#include <linux/wait.h>
-#include <linux/io.h>
-#include <linux/if.h>
-#include <linux/uaccess.h>
-#include <linux/proc_fs.h>
-#include <linux/inetdevice.h>
-#include <linux/reboot.h>
-#include <linux/ethtool.h>
-#include <linux/mii.h>
-#include <linux/in.h>
-#include <linux/if_arp.h>
-#include <linux/if_vlan.h>
-#include <linux/ip.h>
 #include <linux/tcp.h>
+#include <linux/timer.h>
+#include <linux/types.h>
+#include <linux/uaccess.h>
 #include <linux/udp.h>
-#include <linux/crc-ccitt.h>
-#include <linux/crc32.h>
+#include <linux/wait.h>
 
 #include "via-velocity.h"
 
-- 
1.7.9.5
