From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/socket.c: unexport move_addr_to_kernel
Date: Mon, 30 May 2005 22:56:47 +0200
Message-ID: <20050530205647.GW10441@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261751AbVE3U66@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I didn't find any modular usage in the kernel.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 7 May 2005

--- linux-2.6.12-rc3-mm2-full/net/socket.c.old	2005-05-03 11:03:23.000000000 +0200
+++ linux-2.6.12-rc3-mm2-full/net/socket.c	2005-05-03 11:03:53.000000000 +0200
@@ -2070,8 +2070,7 @@
 }
 #endif /* CONFIG_PROC_FS */
 
-/* ABI emulation layers need these two */
-EXPORT_SYMBOL(move_addr_to_kernel);
+/* ABI emulation layers need this one */
 EXPORT_SYMBOL(move_addr_to_user);
 EXPORT_SYMBOL(sock_create);
 EXPORT_SYMBOL(sock_create_kern);
