From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: 2.6.21-rc5-mm3: fix e1000 compilation
Date: Fri, 30 Mar 2007 12:50:30 +0400
Message-ID: <20070330085029.GA6556@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com
To: akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:36260 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933460AbXC3Iml (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 04:42:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  CC [M]  drivers/net/e1000/e1000_main.o
drivers/net/e1000/e1000_main.c: In function 'e1000_tso':
drivers/net/e1000/e1000_main.c:2968: error: dereferencing pointer to incomplete type
	...

--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -32,6 +32,8 @@ #include <linux/init.h>
 #include <linux/vmalloc.h>
 #include <linux/pagemap.h>
 #include <linux/netdevice.h>
+#include <linux/tcp.h>
+#include <linux/ipv6.h>
 #include <net/checksum.h>
 #include <net/ip6_checksum.h>
 #include <linux/mii.h>

