From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/3) wan/cosa - put major number in major.h
Date: Tue, 25 Nov 2003 13:12:02 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031125131202.77d0ca53.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rather than hiding the hard coded major number in the driver, put it
in major.h where conflicts can be spotted.

Jeff, please add to net-drivers-2.5-exp

diff -Nru a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
--- a/drivers/net/wan/cosa.c	Mon Nov 24 15:38:12 2003
+++ b/drivers/net/wan/cosa.c	Mon Nov 24 15:38:12 2003
@@ -90,6 +90,7 @@
 #include <linux/delay.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
+#include <linux/major.h>
 #include <linux/netdevice.h>
 #include <linux/spinlock.h>
 #include <linux/smp_lock.h>
@@ -181,7 +182,7 @@
  * Character device major number. 117 was allocated for us.
  * The value of 0 means to allocate a first free one.
  */
-static int cosa_major = 117;
+static int cosa_major = COSA_MAJOR;
 
 /*
  * Encoding of the minor numbers:
diff -Nru a/include/linux/major.h b/include/linux/major.h
--- a/include/linux/major.h	Mon Nov 24 15:38:12 2003
+++ b/include/linux/major.h	Mon Nov 24 15:38:12 2003
@@ -128,6 +128,8 @@
 
 #define ATARAID_MAJOR		114
 
+#define COSA_MAJOR		117
+
 #define SCSI_DISK8_MAJOR	128
 #define SCSI_DISK9_MAJOR	129
 #define SCSI_DISK10_MAJOR	130
