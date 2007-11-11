From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] unexport sysctl_{r,w}mem_max
Date: Sun, 11 Nov 2007 07:48:37 +0100
Message-ID: <20071111064837.GI21669@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:32866 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756675AbXKKGtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 01:49:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sysctl_{r,w}mem_max can now be unexported.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
d49d51e5f46615c30e0f96c5333733e0ab1c85e6 
diff --git a/net/core/sock.c b/net/core/sock.c
index 8fc2f84..c519b43 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2097,7 +2097,3 @@ EXPORT_SYMBOL(sock_wmalloc);
 EXPORT_SYMBOL(sock_i_uid);
 EXPORT_SYMBOL(sock_i_ino);
 EXPORT_SYMBOL(sysctl_optmem_max);
-#ifdef CONFIG_SYSCTL
-EXPORT_SYMBOL(sysctl_rmem_max);
-EXPORT_SYMBOL(sysctl_wmem_max);
-#endif

