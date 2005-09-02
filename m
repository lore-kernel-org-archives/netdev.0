From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/atm/ioctl.c should #include "common.h"
Date: Fri, 2 Sep 2005 23:24:39 +0200
Message-ID: <20050902212439.GX3657@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161050AbVIBVYu@vger.kernel.org>
To: chas@cmf.nrl.navy.mil
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Every file should #include the header files containing the prototypes of 
it's global functions.

common.h contains the prototype for vcc_ioctl().


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.13-mm1-full/net/atm/ioctl.c.old	2005-09-02 23:01:46.000000000 +0200
+++ linux-2.6.13-mm1-full/net/atm/ioctl.c	2005-09-02 23:17:06.000000000 +0200
@@ -21,6 +21,7 @@
 
 #include "resources.h"
 #include "signaling.h"		/* for WAITING and sigd_attach */
+#include "common.h"
 
 
 static DECLARE_MUTEX(ioctl_mutex);
