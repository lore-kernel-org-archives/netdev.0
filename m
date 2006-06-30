From: akpm@osdl.org
Subject: [patch 4/5] drivers/dma/iovlock.c: make num_pages_spanned() static
Date: Fri, 30 Jun 2006 02:27:22 -0700
Message-ID: <200606300927.k5U9RMob001465@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:8855 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932230AbWF3JtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 05:49:20 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

This patch makes the needlessly global num_pages_spanned() static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/dma/iovlock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/dma/iovlock.c~drivers-dma-iovlockc-make-num_pages_spanned-static drivers/dma/iovlock.c
--- a/drivers/dma/iovlock.c~drivers-dma-iovlockc-make-num_pages_spanned-static
+++ a/drivers/dma/iovlock.c
@@ -31,7 +31,7 @@
 #include <asm/io.h>
 #include <asm/uaccess.h>
 
-int num_pages_spanned(struct iovec *iov)
+static int num_pages_spanned(struct iovec *iov)
 {
 	return
 	((PAGE_ALIGN((unsigned long)iov->iov_base + iov->iov_len) -
_
