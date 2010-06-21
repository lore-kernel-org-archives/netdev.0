From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lasi82596: fix netdev_mc_count conversion
Date: Mon, 21 Jun 2010 13:50:50 -0700 (PDT)
Message-ID: <20100621.135050.48492866.davem@davemloft.net>
References: <20100619223524.GA6018@p100.box>
	<20100619224139.GA6158@p100.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	linux-parisc@vger.kernel.org, kyle@mcmartin.ca, jpirko@redhat.com,
	netdev@vger.kernel.org
To: deller@gmx.de
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20100619224139.GA6158@p100.box>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Helge Deller <deller@gmx.de>
Date: Sun, 20 Jun 2010 00:41:39 +0200

> Fix commit 4cd24eaf0 (net: use netdev_mc_count and netdev_mc_empty when
> appropriate)
> 
> Signed-off-by: Helge Deller <deller@gmx.de>

Applied, please CC: netdev@vger.kernel.org when posting networking
patches in the future, thanks.

> CC: Linus Torvalds <torvalds@linux-foundation.org>
> CC: Kyle McMartin <kyle@mcmartin.ca>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Jiri Pirko <jpirko@redhat.com>
> 
> --- a/drivers/net/lib82596.c
> +++ b/drivers/net/lib82596.c
> @@ -1343,7 +1343,7 @@ static void set_multicast_list(struct net_device *dev)
>  	DEB(DEB_MULTI,
>  	    printk(KERN_DEBUG
>  		   "%s: set multicast list, %d entries, promisc %s, allmulti %s\n",
> -		   dev->name, dev->mc_count,
> +		   dev->name, netdev_mc_count(dev),
>  		   dev->flags & IFF_PROMISC ? "ON" : "OFF",
>  		   dev->flags & IFF_ALLMULTI ? "ON" : "OFF"));
>  
> 
