From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Add C99 initializers to ethtool.c
Date: Thu, 19 Feb 2004 19:24:54 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <403553D6.60101@pobox.com>
References: <20040219001633.GC9704@artsapartment.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Art Haas <ahaas@airmail.net>
In-Reply-To: <20040219001633.GC9704@artsapartment.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Art Haas wrote:
> Hi.
> 
> Here's a little patch adding C99 initializers to ethtool.c. The patch is
> against the current BK, and the file has been recompiled with the
> changes successfully.
> 
> This patch and the one I just sent for the netfilter file were changed
> to make the code easier to read and to remove warnings if a '-W' flag is
> added to the compile command.
> 
> Art Haas
> 
> ===== net/core/ethtool.c 1.9 vs edited =====
> --- 1.9/net/core/ethtool.c	Sun Oct 12 06:18:38 2003
> +++ edited/net/core/ethtool.c	Wed Feb 18 17:22:52 2004
> @@ -76,7 +76,7 @@
>  
>  static int ethtool_get_settings(struct net_device *dev, void *useraddr)
>  {
> -	struct ethtool_cmd cmd = { ETHTOOL_GSET };
> +	struct ethtool_cmd cmd = { .cmd = ETHTOOL_GSET };
>  	int err;
>  
>  	if (!dev->ethtool_ops->get_settings)
> @@ -168,7 +168,7 @@
>  
>  static int ethtool_get_wol(struct net_device *dev, char *useraddr)
>  {
> -	struct ethtool_wolinfo wol = { ETHTOOL_GWOL };
> +	struct ethtool_wolinfo wol = { .cmd = ETHTOOL_GWOL };
>  
>  	if (!dev->ethtool_ops->get_wol)
>  		return -EOPNOTSUPP;

Since it doesn't warn without -W, I would rather leave it in its more 
compact form...

	Jeff
