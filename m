From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] LLC -- get rid of warning
Date: Tue, 23 Sep 2003 13:54:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923135426.4f85b7fb.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mike Phillips <mikep@linuxtr.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In 2.6.0-test5 bk latest, if token ring is configured, then a warning is
generated about a missing prototype for tr_source_route.

diff -Nru a/net/llc/llc_output.c b/net/llc/llc_output.c
--- a/net/llc/llc_output.c	Tue Sep 23 12:56:04 2003
+++ b/net/llc/llc_output.c	Tue Sep 23 12:56:04 2003
@@ -16,6 +16,7 @@
 #include <linux/if_arp.h>
 #include <linux/if_tr.h>
 #include <linux/netdevice.h>
+#include <linux/trdevice.h>
 #include <linux/skbuff.h>
 #include <net/llc.h>
 #include <net/llc_pdu.h>
