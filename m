From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [patch 1/1 2.4] e1000 update - reset default ITR value to 8000
Date: Mon, 27 Sep 2004 09:34:10 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409270932420.5998-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.4/drivers/net/e1000/e1000_param.c linux-2.4/drivers/net/e1000.new/e1000_param.c
--- linux-2.4/drivers/net/e1000/e1000_param.c	2004-09-20 21:21:20.000000000 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_param.c	2004-09-20 21:32:07.000000000 -0700
@@ -211,7 +211,7 @@ E1000_PARAM(InterruptThrottleRate, "Inte
 #define MAX_TXABSDELAY            0xFFFF
 #define MIN_TXABSDELAY                 0
 
-#define DEFAULT_ITR                    1
+#define DEFAULT_ITR                 8000 
 #define MAX_ITR                   100000
 #define MIN_ITR                      100
 
