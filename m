From: Adrian Bunk <bunk@stusta.de>
Subject: [patch] net/core/pktgen.c shouldn't include pci.h
Date: Sat, 13 Nov 2004 15:53:51 +0100
Message-ID: <20041113145351.GZ2249@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262766AbUKMOy1@vger.kernel.org>
To: Robert Olsson <robert.olsson@its.uu.se>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If rebuilding after touching pci.h in 2.6, net/core/pktgen.c is the only 
file under net/ that gets rebuilt.

I searched and didn't find any reason why net/core/pktgen.c needs to 
include pci.h .

I'm therefore suggesting the patch below (applies against both 2.4
and 2.6).


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.10-rc1-mm5-full/net/core/pktgen.c.old	2004-11-13 14:37:43.000000000 +0100
+++ linux-2.6.10-rc1-mm5-full/net/core/pktgen.c	2004-11-13 14:40:07.000000000 +0100
@@ -69,7 +69,6 @@
 #include <linux/ioport.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
-#include <linux/pci.h>
 #include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/inet.h>
