From: maximilian attems <janitor@sternwelten.at>
Subject: [patch-kj] net/econet/af_econet.c fix warning xyz never used
Date: Mon, 21 Jun 2004 19:09:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040621170904.GD1545@sputnik.stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: <WHarms@bfs.de>(Walter Harms)
moving the define a bit higher removes two useless warnings.

regards,
walter

Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.7-max/net/econet/af_econet.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/econet/af_econet.c~fix-warning-af_econet net/econet/af_econet.c
--- linux-2.6.7/net/econet/af_econet.c~fix-warning-af_econet	2004-06-18 10:20:06.000000000 +0200
+++ linux-2.6.7-max/net/econet/af_econet.c	2004-06-18 10:20:06.000000000 +0200
@@ -255,9 +255,9 @@ static int econet_sendmsg(struct kiocb *
 	struct ec_addr addr;
 	int err;
 	unsigned char port, cb;
+#ifdef CONFIG_ECONET_NATIVE
 	struct sk_buff *skb;
 	struct ec_cb *eb;
-#ifdef CONFIG_ECONET_NATIVE
 	unsigned short proto = 0;
 #endif
 #ifdef CONFIG_ECONET_AUNUDP
