From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] janitor: remove unneeded includes (tokenring)
Date: Wed, 17 Sep 2003 15:27:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030917152724.342327e9.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, mikep@linuxtr.net, linux-tr@linuxtr.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

Please apply to 2.6.0-test5-current.

Thanks,
--
~Randy


From: Randy Hron <rwhron@earthlink.net>

 linux-260-test5-kj-rddunlap/drivers/net/tokenring/lanstreamer.h |    2 ++
 linux-260-test5-kj-rddunlap/drivers/net/tokenring/smctr.c       |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/tokenring/tms380tr.c    |    1 -
 3 files changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/tokenring/lanstreamer.h~drivers_net_tokenring drivers/net/tokenring/lanstreamer.h
--- linux-260-test5-kj/drivers/net/tokenring/lanstreamer.h~drivers_net_tokenring	2003-09-11 10:42:06.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/tokenring/lanstreamer.h	2003-09-11 10:42:06.000000000 -0700
@@ -60,6 +60,8 @@
  *
  */
 
+#include <linux/version.h>
+
 #if STREAMER_IOCTL && (LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0))
 #include <asm/ioctl.h>
 #define IOCTL_PRINT_RX_BUFS   SIOCDEVPRIVATE
diff -puN drivers/net/tokenring/smctr.c~drivers_net_tokenring drivers/net/tokenring/smctr.c
--- linux-260-test5-kj/drivers/net/tokenring/smctr.c~drivers_net_tokenring	2003-09-11 10:42:06.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/tokenring/smctr.c	2003-09-11 10:42:06.000000000 -0700
@@ -29,7 +29,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/config.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
diff -puN drivers/net/tokenring/tms380tr.c~drivers_net_tokenring drivers/net/tokenring/tms380tr.c
--- linux-260-test5-kj/drivers/net/tokenring/tms380tr.c~drivers_net_tokenring	2003-09-11 10:42:06.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/tokenring/tms380tr.c	2003-09-11 10:42:06.000000000 -0700
@@ -77,7 +77,6 @@ static const char version[] = "tms380tr.
 #endif
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/fcntl.h>

_
