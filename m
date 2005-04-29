From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.4 2/16] e1000: Fix msec-delay definition
 to use msleep
Date: Thu, 28 Apr 2005 20:09:39 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281957540.30085-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix msec-delay definition in e1000_osdep.h to use msleep 

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000_osdep.h net-drivers-2.4/drivers/net/e1000.new/e1000_osdep.h
--- net-drivers-2.4/drivers/net/e1000/e1000_osdep.h	2005-04-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_osdep.h	2005-04-12 23:00:55.000000000 -0700
@@ -46,9 +46,9 @@
 				/* Don't mdelay in interrupt context! */ \
 	                	BUG(); \
 			} else { \
-				set_current_state(TASK_UNINTERRUPTIBLE); \
-				schedule_timeout((x * HZ)/1000 + 2); \
+				msleep(x); \
 			} } while(0)
+
 /* Some workarounds require millisecond delays and are run during interrupt
  * context.  Most notably, when establishing link, the phy may need tweaking
  * but cannot process phy register reads/writes faster than millisecond
