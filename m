From: Adrian Bunk <bunk@fs.tum.de>
Subject: [2.6 patch] remove a superfluous #ifndef from net/ip.h
Date: Sun, 27 Jun 2004 02:02:23 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040627000222.GQ18303@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S267237AbUF0AC2@vger.kernel.org>
To: netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

The patch below removes a superfluous #ifndef from net/ip.h (snmp.h is 
guarded by the same #ifndef).

Signed-off-by: Adrian Bunk <bunk@fs.tum.de>

Please apply
Adrian

--- linux-2.6.7-mm2-full/include/net/ip.h.old	2004-06-26 16:28:13.000000000 +0200
+++ linux-2.6.7-mm2-full/include/net/ip.h	2004-06-26 16:28:24.000000000 +0200
@@ -32,10 +32,7 @@
 #include <linux/in_route.h>
 #include <net/route.h>
 #include <net/arp.h>
-
-#ifndef _SNMP_H
 #include <net/snmp.h>
-#endif
 
 struct sock;
 
