From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] pppoe: remove unneeded ifdef/endif
Date: Mon, 23 Feb 2004 13:42:07 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223134207.656a5213.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


hi,
Please apply to 2.6.3-current.

--
~Randy


From: Luiz Fernando Capitulino <lcapitulino@prefeitura.sp.gov.br>


hi all,

this #ifdef/#endif is not needed:

diff -X dontdiff -Nru linux-2.6.2-rc2-bk2/drivers/net/pppoe.c linux-2.6.2-rc2-bk2~/drivers/net/pppoe.c


 linux-263-kj1-rddunlap/drivers/net/pppoe.c |    2 --
 1 files changed, 2 deletions(-)

diff -puN drivers/net/pppoe.c~net_pppoe_rmproc drivers/net/pppoe.c
--- linux-263-kj1/drivers/net/pppoe.c~net_pppoe_rmproc	2004-02-18 14:45:57.000000000 -0800
+++ linux-263-kj1-rddunlap/drivers/net/pppoe.c	2004-02-18 14:45:57.000000000 -0800
@@ -1146,9 +1146,7 @@ static void __exit pppoe_exit(void)
 	dev_remove_pack(&pppoes_ptype);
 	dev_remove_pack(&pppoed_ptype);
 	unregister_netdevice_notifier(&pppoe_notifier);
-#ifdef CONFIG_PROC_FS
 	remove_proc_entry("pppoe", proc_net);
-#endif
 }
 
 module_init(pppoe_init);

_
