From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] skge: remove unused var.
Date: Mon, 23 Feb 2004 13:43:19 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223134319.04a532c5.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.3-current.

--
~Randy


From: Stephen Hemminger <shemminger@osdl.org>



Get rid of unused local variable that causes warning

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c


 linux-263-kj1-rddunlap/drivers/net/sk98lin/skge.c |    1 -
 1 files changed, 1 deletion(-)

diff -puN drivers/net/sk98lin/skge.c~net_skge_unused drivers/net/sk98lin/skge.c
--- linux-263-kj1/drivers/net/sk98lin/skge.c~net_skge_unused	2004-02-18 14:46:07.000000000 -0800
+++ linux-263-kj1-rddunlap/drivers/net/sk98lin/skge.c	2004-02-18 14:46:07.000000000 -0800
@@ -294,7 +294,6 @@ static int __init skge_probe (void)
 	SK_BOOL BootStringCount = SK_FALSE;
 	int			retval;
 #ifdef CONFIG_PROC_FS
-	int			proc_root_initialized = 0;
 	struct proc_dir_entry	*pProcFile;
 #endif
 

_
