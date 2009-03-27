From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] Fix "error: implicit declaration of function
	'page_address'"
Date: Fri, 27 Mar 2009 18:53:27 +0300
Message-ID: <20090327155327.GA14867@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:14094 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587AbZC0PqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 11:46:05 -0400
Received: by fg-out-1718.google.com with SMTP id 16so3407fgg.17
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2009 08:46:02 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As seen on mips:

In file included from include/net/sock.h:50,
                 from security/selinux/avc.c:25:
include/linux/netdevice.h: In function 'skb_gro_mac_header':
include/linux/netdevice.h:1132: error: implicit declaration of function 'page_address'
include/linux/netdevice.h:1133: warning: pointer/integer type mismatch in conditional expression

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/netdevice.h |    1 +
 1 file changed, 1 insertion(+)

--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -32,6 +32,7 @@
 #ifdef __KERNEL__
 #include <linux/timer.h>
 #include <linux/delay.h>
+#include <linux/mm.h>
 #include <asm/atomic.h>
 #include <asm/cache.h>
 #include <asm/byteorder.h>
