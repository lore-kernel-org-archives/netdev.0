From: Matt Mackall <mpm@selenic.com>
Subject: Re: netpoll warning in tulip
Date: Tue, 16 Mar 2004 13:23:48 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040316192347.GC11010@waste.org>
References: <Pine.GSO.4.44.0403161235170.29946-100000@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Meelis Roos <mroos@linux.ee>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.44.0403161235170.29946-100000@math.ut.ee>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 16, 2004 at 12:36:02PM +0200, Meelis Roos wrote:
> FYI: with netpoll configured out, I get
> 
>   CC [M]  drivers/net/tulip/tulip_core.o
> drivers/net/tulip/tulip_core.c:256: warning: `poll_tulip' declared `static' but never defined

 2.6.5-rc1-mpm/drivers/net/tulip/tulip_core.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff -puN drivers/net/tulip/tulip_core.c~tulip-poll drivers/net/tulip/tulip_core.c
--- 2.6.5-rc1/drivers/net/tulip/tulip_core.c~tulip-poll	2004-03-16 13:21:38.000000000 -0600
+++ 2.6.5-rc1-mpm/drivers/net/tulip/tulip_core.c	2004-03-16 13:22:30.000000000 -0600
@@ -253,8 +253,9 @@ static void tulip_down(struct net_device
 static struct net_device_stats *tulip_get_stats(struct net_device *dev);
 static int private_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static void set_rx_mode(struct net_device *dev);
+#ifdef CONFIG_NET_POLL_CONTROLLER
 static void poll_tulip(struct net_device *dev);
-
+#endif
 
 static void tulip_set_power_state (struct tulip_private *tp,
 				   int sleep, int snooze)

_


-- 
Matt Mackall : http://www.selenic.com : Linux development and consulting
