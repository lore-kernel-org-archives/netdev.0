From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/bluetooth/rfcomm/core.: make a variable static
Date: Tue, 15 Mar 2005 15:39:03 +0100
Message-ID: <20050315143903.GK3189@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bluez-devel@lists.sourceforge.net, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
To: marcel@holtmann.org, maxk@qualcomm.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch makes a needlessly global variable static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.11-mm3-full/net/bluetooth/rfcomm/core.c.old	2005-03-15 13:21:50.000000000 +0100
+++ linux-2.6.11-mm3-full/net/bluetooth/rfcomm/core.c	2005-03-15 13:22:03.000000000 +0100
@@ -68,7 +68,7 @@
 #define rfcomm_lock()	down(&rfcomm_sem);
 #define rfcomm_unlock()	up(&rfcomm_sem);
 
-unsigned long rfcomm_event;
+static unsigned long rfcomm_event;
 
 static LIST_HEAD(session_list);
 static atomic_t terminate, running;
