From: Felipe W Damasio <felipewd@terra.com.br>
Subject: [PATCH] Kill unneeded linux/version.h include in net/ipv6
Date: Wed, 03 Sep 2003 11:04:13 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F55F4DD.9070301@terra.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020308040205020607070106"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi, davem@redhat.com, yoshfuji@linux-ipv6.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020308040205020607070106
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

	Hi,

	Patch against 2.6-test4.

	Removes an unneeded linux/version.h include from af_inet6..

	Please consider applying.

	Cheers,

Felipe

--------------020308040205020607070106
Content-Type: text/plain;
 name="ipv6-checkversion.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipv6-checkversion.patch"

--- linux-2.6.0-test4/net/ipv6/af_inet6.c	Fri Aug 22 20:56:34 2003
+++ linux-2.6.0-test4-fwd/net/ipv6/af_inet6.c	Wed Sep  3 10:58:48 2003
@@ -40,7 +40,6 @@
 #include <linux/proc_fs.h>
 #include <linux/stat.h>
 #include <linux/init.h>
-#include <linux/version.h>
 
 #include <linux/inet.h>
 #include <linux/netdevice.h>

--------------020308040205020607070106--
