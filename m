From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] yam: function needs a return
Date: Wed, 27 Aug 2003 22:06:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030827220612.52553e1d.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jpr@f6fbb.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply.

patch_name:	yam_retval.patch
patch_version:	2003-08-27.18:19:03
author:		Randy.Dunlap <rddunlap@osdl.org>
description:	yam: function needs a return statement;
product:	Linux
product_versions: 260-test4
maintainer:	jpr@f6fbb.org

diff -Naur ./drivers/net/hamradio/yam.c~retval ./drivers/net/hamradio/yam.c
--- ./drivers/net/hamradio/yam.c~retval	Fri Aug 22 16:58:10 2003
+++ ./drivers/net/hamradio/yam.c	Wed Aug 27 12:03:13 2003
@@ -807,7 +807,7 @@
 	seq_printf(seq, "  RxInt    %u\n", yp->nb_rxint);
 	seq_printf(seq, "  RxOver   %lu\n", yp->stats.rx_fifo_errors);
 	seq_printf(seq, "\n");
-
+	return 0;
 }
 
 static struct seq_operations yam_seqops = {

--
~Randy
