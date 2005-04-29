From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 10/11] ixgb: Fixed msec_delay in
 osdep to use msleep
Date: Thu, 28 Apr 2005 19:05:12 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281900580.28003-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fixed msec_delay in osdep to use msleep

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_osdep.h net-drivers-2.6/drivers/net/ixgb.new/ixgb_osdep.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb_osdep.h	2005-04-05 23:06:36.332229456 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_osdep.h	2005-04-05 23:06:38.300930168 -0700
@@ -45,8 +45,7 @@
 				/* Don't mdelay in interrupt context! */ \
 	                	BUG(); \
 			} else { \
-				set_current_state(TASK_UNINTERRUPTIBLE); \
-				schedule_timeout((x * HZ)/1000 + 2); \
+				msleep(x); \
 			} } while(0)
 #endif
 
