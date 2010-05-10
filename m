From: kaber@trash.net
Subject: [PATCH 65/84] Restore __ALIGN_MASK()
Date: Mon, 10 May 2010 22:18:36 +0200
Message-ID: <1273522735-24672-66-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54523 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756926Ab0EJUT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:27 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>

Fix lib/bitmap.c compile failure due to __ALIGN_KERNEL changes.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/kernel.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 284ea99..db6717d 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -40,6 +40,7 @@ extern const char linux_proc_banner[];
 #define STACK_MAGIC	0xdeadbeef
 
 #define ALIGN(x, a)		__ALIGN_KERNEL((x), (a))
+#define __ALIGN_MASK(x, mask)	__ALIGN_KERNEL_MASK((x), (mask))
 #define PTR_ALIGN(p, a)		((typeof(p))ALIGN((unsigned long)(p), (a)))
 #define IS_ALIGNED(x, a)		(((x) & ((typeof(x))(a) - 1)) == 0)
 
-- 
1.7.0.4

