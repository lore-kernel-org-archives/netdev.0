From: Mads Martin =?iso-8859-1?Q?J=F8rgensen?= <mmj@suse.de>
Subject: /usr/src/linux/Documentation/networking/ifenslave.c
Date: Wed, 16 Jul 2003 11:23:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030716092354.GC24077@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

$SUBJECT is a userspace tool, but includes kernel headers. This small
obvious patch against 2.6.0-test1 should fix it.

--- ifenslave.c
+++ ifenslave.c
@@ -97,8 +97,7 @@
 #include <sys/types.h>
 #include <sys/socket.h>
 #include <sys/ioctl.h>
-#include <linux/if.h>
-#include <linux/if_arp.h>
+#include <net/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/if_bonding.h>
 #include <linux/sockios.h>

-- 
Mads Martin Joergensen, http://mmj.dk
"Why make things difficult, when it is possible to make them cryptic
 and totally illogical, with just a little bit more effort?"
                                -- A. P. J.
