From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] remove dead extern's in netdevice.h
Date: 02 Mar 2005 16:36:49 -0500
Message-ID: <1109799408.1098.193.camel@jzny.localdomain>
References: <20050302105902.72f2b983@dxpl.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Jeff Garzik <jgarzik@pobox.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050302105902.72f2b983@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


If you want to do this, you might as well kill hardware flow control.
I dont remember what the last decision was when we last pinged people.
Jeff?

cheers,
jamal

On Wed, 2005-03-02 at 13:59, Stephen Hemminger wrote:
> The following definitions are historical relics.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
> --- a/include/linux/netdevice.h	2005-03-02 10:53:22 -08:00
> +++ b/include/linux/netdevice.h	2005-03-02 10:53:22 -08:00
> @@ -921,8 +921,6 @@
>  extern void		dev_mcast_init(void);
>  extern int		netdev_max_backlog;
>  extern int		weight_p;
> -extern unsigned long	netdev_fc_xoff;
> -extern atomic_t netdev_dropping;
>  extern int		netdev_set_master(struct net_device *dev, struct net_device *master);
>  extern int skb_checksum_help(struct sk_buff *skb, int inward);
>  /* rx skb timestamps */
> 
> 
