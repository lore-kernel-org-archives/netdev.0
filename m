From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATRCH] janitor: hermes: delete verify_area call
Date: Thu, 25 Sep 2003 21:59:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925215902.57f53822.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hermes@gibson.dropbear.id.au, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.0-test5-current.

Thanks,
--
~Randy


From: Domen Puncer <domen@coderock.org>

IMO, that verify_area wasn't needed.



 linux-260-t5bk12-kj-rddunlap/drivers/net/wireless/orinoco.c |    4 ----
 1 files changed, 4 deletions(-)

diff -puN drivers/net/wireless/orinoco.c~net_wireless_orinoco_verify drivers/net/wireless/orinoco.c
--- linux-260-t5bk12-kj/drivers/net/wireless/orinoco.c~net_wireless_orinoco_verify	2003-09-25 16:03:17.000000000 -0700
+++ linux-260-t5bk12-kj-rddunlap/drivers/net/wireless/orinoco.c	2003-09-25 16:03:17.000000000 -0700
@@ -3833,10 +3833,6 @@ orinoco_ioctl(struct net_device *dev, st
 				{ SIOCIWLASTPRIV, 0, 0, "dump_recs" },
 			};
 
-			err = verify_area(VERIFY_WRITE, wrq->u.data.pointer, sizeof(privtab));
-			if (err)
-				break;
-			
 			wrq->u.data.length = sizeof(privtab) / sizeof(privtab[0]);
 			if (copy_to_user(wrq->u.data.pointer, privtab, sizeof(privtab)))
 				err = -EFAULT;

_
