From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] wan: remove multi-line string literal
Date: Fri, 19 Sep 2003 11:27:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030919112746.3df80578.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ncorbic@sangoma.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Please apply to 2.6.0-test5-current.

--
~Randy


patch_name:	sdla_2line_string.patch
patch_version:	2003-09-19.10:29:52
author:		Randy.Dunlap <rddunlap@osdl.org>
description:	remove deprecated multi-line string literal;
product:	Linux
product_versions: 2.6.0-test5
maintainer:	Nenad Corbic <ncorbic@sangoma.com>
diffstat:	=
 drivers/net/wan/sdla_chdlc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff -Naurp ./drivers/net/wan/sdla_chdlc.c~fixstring ./drivers/net/wan/sdla_chdlc.c
--- ./drivers/net/wan/sdla_chdlc.c~fixstring	2003-09-08 12:50:06.000000000 -0700
+++ ./drivers/net/wan/sdla_chdlc.c	2003-09-19 10:25:43.000000000 -0700
@@ -560,8 +560,8 @@ int wpc_init (sdla_t* card, wandev_conf_
 	
 
 		if (chdlc_set_intr_mode(card, APP_INT_ON_TIMER)){
-			printk (KERN_INFO "%s: 
-				Failed to set interrupt triggers!\n",
+			printk (KERN_INFO "%s: "
+				"Failed to set interrupt triggers!\n",
 				card->devname);
 			return -EIO;	
         	}
