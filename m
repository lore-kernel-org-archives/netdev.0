From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/char/random.c: unexport secure_ipv6_port_ephemeral
Date: Sun, 9 Apr 2006 17:58:22 +0200
Message-ID: <20060409155822.GI8454@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mpm@selenic.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750808AbWDIP6k@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the unused EXPORT_SYMBOL(secure_ipv6_port_ephemeral).

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 5 Apr 2006

--- linux-2.6.17-rc1-mm1-full/drivers/char/random.c.old	2006-04-05 17:00:04.000000000 +0200
+++ linux-2.6.17-rc1-mm1-full/drivers/char/random.c	2006-04-05 17:00:22.000000000 +0200
@@ -1584,7 +1584,6 @@
 
 	return twothirdsMD4Transform(daddr, hash);
 }
-EXPORT_SYMBOL(secure_ipv6_port_ephemeral);
 #endif
 
 #if defined(CONFIG_IP_DCCP) || defined(CONFIG_IP_DCCP_MODULE)
