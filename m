From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Fw: [PATCH] Kill unneeded version.h in net/wanrouter
Date: Wed, 3 Sep 2003 08:29:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030903082958.582cc0c5.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart_Wed__3_Sep_2003_08:29:58_-0700_09464040"
Cc: felipewd@terra.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart_Wed__3_Sep_2003_08:29:58_-0700_09464040
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit


net/ patches should go to netdev@oss.sgi.com ............

~Randy


Begin forwarded message:

Date: Wed, 03 Sep 2003 11:26:47 -0300
From: Felipe W Damasio <felipewd@terra.com.br>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: [PATCH] Kill unneeded version.h in net/wanrouter


	Hi,

	Patch against linux-2.6.0-test4.

	Please apply.

	Thanks,

Felipe

--Multipart_Wed__3_Sep_2003_08:29:58_-0700_09464040
Content-Type: text/plain;
 name="wanrouter-checkversion.patch"
Content-Disposition: attachment;
 filename="wanrouter-checkversion.patch"
Content-Transfer-Encoding: 7bit

diff -u -X ./dontdiff linux-2.6.0-test4/net/wanrouter/af_wanpipe.c linux-2.6.0-test4-fwd/net/wanrouter/af_wanpipe.c
--- linux-2.6.0-test4/net/wanrouter/af_wanpipe.c	Fri Aug 22 21:01:48 2003
+++ linux-2.6.0-test4-fwd/net/wanrouter/af_wanpipe.c	Wed Sep  3 11:05:45 2003
@@ -32,7 +32,6 @@
 *
 ******************************************************************************/
 
-#include <linux/version.h>
 #include <linux/config.h>
 #include <linux/types.h>
 #include <linux/sched.h>
diff -u -X ./dontdiff linux-2.6.0-test4/net/wanrouter/wanmain.c linux-2.6.0-test4-fwd/net/wanrouter/wanmain.c
--- linux-2.6.0-test4/net/wanrouter/wanmain.c	Fri Aug 22 20:57:53 2003
+++ linux-2.6.0-test4-fwd/net/wanrouter/wanmain.c	Wed Sep  3 11:05:33 2003
@@ -42,7 +42,6 @@
 * Jun 02, 1999  Gideon Hack	Updates for Linux 2.0.X and 2.2.X kernels.
 *****************************************************************************/
 
-#include <linux/version.h>
 #include <linux/config.h>
 #include <linux/stddef.h>	/* offsetof(), etc. */
 #include <linux/errno.h>	/* return codes */


--Multipart_Wed__3_Sep_2003_08:29:58_-0700_09464040--
