From: Andi Kleen <ak@suse.de>
Subject: [PATCH] Fix gcc4 compilation in s2io
Date: Mon, 10 Jan 2005 03:52:53 +0100
Message-ID: <20050110025253.GB5672@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, raghavendra.koushik@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Fix gcc 4 compilation in the s2io driver

Signed-off-by: Andi Kleen <ak@suse.de>

Index: linux/drivers/net/s2io.h
===================================================================
--- linux.orig/drivers/net/s2io.h	2005-01-09 18:19:25.%N +0100
+++ linux/drivers/net/s2io.h	2005-01-09 19:04:40.%N +0100
@@ -740,8 +740,8 @@
 {
 	u64 ret = 0;
 	ret = readl(addr + 4);
-	(u64) ret <<= 32;
-	(u64) ret |= readl(addr);
+	ret <<= 32;
+	ret |= readl(addr);
 
 	return ret;
 }
