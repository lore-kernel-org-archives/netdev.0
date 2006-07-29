From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] include/linux/netfilter_bridge.h: header cleanup
Date: Sat, 29 Jul 2006 11:45:45 +0400
Message-ID: <20060729074545.GA6843@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:30693 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1422687AbWG2Hps (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jul 2006 03:45:48 -0400
Received: by nf-out-0910.google.com with SMTP id o25so46190nfa
        for <netdev@vger.kernel.org>; Sat, 29 Jul 2006 00:45:46 -0700 (PDT)
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Header doesn't use anything from atomic.h.
It fixes headers_check warning:

include/linux/netfilter_bridge.h requires asm/atomic.h, which does not exist

Compile tested on
alpha     arm   i386-up  sparc    sparc64-up  x86_64
alpha-up  i386           sparc64  sparc-up    x86_64-up

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/netfilter_bridge.h |    1 -
 1 file changed, 1 deletion(-)

--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -6,7 +6,6 @@ #define __LINUX_BRIDGE_NETFILTER_H
 
 #include <linux/netfilter.h>
 #if defined(__KERNEL__) && defined(CONFIG_BRIDGE_NETFILTER)
-#include <asm/atomic.h>
 #include <linux/if_ether.h>
 #endif
 

