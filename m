From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] (1/4) sdla - move out of Space.c
Date: Wed, 10 Sep 2003 23:00:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030910230048.A17453@electric-eye.fr.zoreil.com>
References: <20030908141439.2e41b516.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030908141439.2e41b516.shemminger@osdl.org>; from shemminger@osdl.org on Mon, Sep 08, 2003 at 02:14:39PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Apply on top of 2.6.0-test5-bk1 + Stephen sdla patches. Compiles fine.


free_netdev() patrol.


 drivers/net/wan/sdla.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/wan/sdla.c~sh-sdla-free_netdev drivers/net/wan/sdla.c
--- linux-2.6.0-test5-bk1/drivers/net/wan/sdla.c~sh-sdla-free_netdev	Wed Sep 10 22:41:19 2003
+++ linux-2.6.0-test5-bk1-fr/drivers/net/wan/sdla.c	Wed Sep 10 22:42:35 2003
@@ -1669,7 +1669,7 @@ static int __init init_sdla(void)
 
 	err = register_netdev(sdla);
 	if (err) 
-		kfree(sdla);
+		free_netdev(sdla);
 
 	return err;
 }

_
