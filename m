From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] [WAN] use module_exit in sdladrv
Date: Thu, 18 Sep 2003 11:21:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030918112106.198f3677.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ncorbic@sangoma.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.0-test5-current.

Thanks,
--
~Randy


patch_name:	sdladrv_module.patch
patch_version:	2003-09-18.11:30:51
author:		Randy.Dunlap <rddunlap@osdl.org>
description:	use "module_exit" instead of "module_cleanup";
product:	Linux
product_versions: 2.6.0-test5
maintainer:	ncorbic@sangoma.com
diffstat:	=
 drivers/net/wan/sdladrv.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -Naurp ./drivers/net/wan/sdladrv.c~sdlamod ./drivers/net/wan/sdladrv.c
--- ./drivers/net/wan/sdladrv.c~sdlamod	2003-09-08 12:49:58.000000000 -0700
+++ ./drivers/net/wan/sdladrv.c	2003-09-18 11:29:29.000000000 -0700
@@ -351,7 +351,7 @@ static void sdladrv_cleanup(void)
 }
 
 module_init(sdladrv_init);
-module_cleanup(sdladrv_cleanup);
+module_exit(sdladrv_cleanup);
 #endif
 
 /******* Kernel APIs ********************************************************/
