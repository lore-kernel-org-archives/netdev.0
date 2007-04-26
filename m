From: akpm@linux-foundation.org
Subject: [patch 07/15] iucv: fix compilation on s390-up
Date: Thu, 26 Apr 2007 00:27:26 -0700
Message-ID: <200704260727.l3Q7RQWQ023961@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	adobriyan@gmail.com, heiko.carstens@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:42915 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933410AbXDZH2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:28:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>

  CC [M]  net/iucv/iucv.o
net/iucv/iucv.c: In function 'iucv_init':
net/iucv/iucv.c:1556: error: 'iucv_cpu_notifier' undeclared (first use in this function)

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/iucv/iucv.c |    2 --
 1 file changed, 2 deletions(-)

diff -puN net/iucv/iucv.c~iucv-fix-compilation-on-s390-up net/iucv/iucv.c
--- a/net/iucv/iucv.c~iucv-fix-compilation-on-s390-up
+++ a/net/iucv/iucv.c
@@ -519,7 +519,6 @@ static void iucv_disable(void)
 	kfree(iucv_path_table);
 }
 
-#ifdef CONFIG_HOTPLUG_CPU
 static int __cpuinit iucv_cpu_notify(struct notifier_block *self,
 				     unsigned long action, void *hcpu)
 {
@@ -565,7 +564,6 @@ static int __cpuinit iucv_cpu_notify(str
 static struct notifier_block iucv_cpu_notifier = {
 	.notifier_call = iucv_cpu_notify,
 };
-#endif
 
 /**
  * iucv_sever_pathid
_
