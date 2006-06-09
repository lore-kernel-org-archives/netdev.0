From: akpm@osdl.org
Subject: [patch 1/8] myri10ge: alpha build fix
Date: Thu, 08 Jun 2006 22:19:41 -0700
Message-ID: <200606090519.k595JfxP032014@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:45787 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965143AbWFIFTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 01:19:51 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Andrew Morton <akpm@osdl.org>

drivers/net/myri10ge/myri10ge.c: In function 'myri10ge_submit_8rx':
drivers/net/myri10ge/myri10ge.c:772: error: 'DMA_32BIT_MASK' undeclared (first use in this function)
drivers/net/myri10ge/myri10ge.c:772: error: (Each undeclared identifier is reported only once
drivers/net/myri10ge/myri10ge.c:772: error: for each function it appears in.)
drivers/net/myri10ge/myri10ge.c: In function 'myri10ge_probe':
drivers/net/myri10ge/myri10ge.c:2607: error: 'DMA_64BIT_MASK' undeclared (first use in this function)
drivers/net/myri10ge/myri10ge.c:2612: error: 'DMA_32BIT_MASK' undeclared (first use in this function)

Cc: Brice Goglin <brice@myri.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/myri10ge/myri10ge.c |    2 ++
 1 file changed, 2 insertions(+)

diff -puN drivers/net/myri10ge/myri10ge.c~myri10ge-alpha-build-fix drivers/net/myri10ge/myri10ge.c
--- devel/drivers/net/myri10ge/myri10ge.c~myri10ge-alpha-build-fix	2006-06-03 21:13:30.000000000 -0700
+++ devel-akpm/drivers/net/myri10ge/myri10ge.c	2006-06-03 21:13:43.000000000 -0700
@@ -59,6 +59,8 @@
 #include <linux/crc32.h>
 #include <linux/moduleparam.h>
 #include <linux/io.h>
+#include <linux/dma-mapping.h>
+
 #include <net/checksum.h>
 #include <asm/byteorder.h>
 #include <asm/io.h>
_
