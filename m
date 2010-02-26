From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [net-next-2.6 PATCH] net: convert multiple drivers to use
 netdev_for_each_mc_addr, part5 V2
Date: Fri, 26 Feb 2010 11:12:25 +0100
Message-ID: <20100226101224.GC2650@psychotron.redhat.com>
References: <20100223191948.GE2673@psychotron.redhat.com>
 <20100226.014953.203661752.davem@davemloft.net>
 <20100226.020333.13570565.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62080 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933355Ab0BZKM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 05:12:28 -0500
Content-Disposition: inline
In-Reply-To: <20100226.020333.13570565.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 26, 2010 at 11:03:33AM CET, davem@davemloft.net wrote:
>
>100 EURO says you didn't compile test this.
>
>@@ -975,7 +968,7 @@ static void do_set_multicast_list(struct net_device *dev)
> 
>   	if(dev->flags&IFF_PROMISC)
>   		ei_outb_p(E8390_RXCONFIG | 0x18, e8390_base + EN0_RXCR);
>-	else if(dev->flags&IFF_ALLMULTI || dev->mc_list)
>+	else if (dev->flags & IFF_ALLMULTI || !netdev_mc_addr(dev))
>   		ei_outb_p(E8390_RXCONFIG | 0x08, e8390_base + EN0_RXCR);
>   	else
>   		ei_outb_p(E8390_RXCONFIG, e8390_base + EN0_RXCR);
>
>I'll fix it up, but you have to start getting proper build
>coverage of your patches!
>
>I really don't care how slow your netbook is, this case could have
>been easily prevented.

I'm really sorry, I do compile test all my patches, but I must have missed this
:(

I promise I'll reserve 2xtime next time. You'll have a beer on me :)

Jirka
