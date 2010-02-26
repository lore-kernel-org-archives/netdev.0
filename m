From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] net: convert multiple drivers to use
 netdev_for_each_mc_addr, part5 V2
Date: Fri, 26 Feb 2010 02:03:33 -0800 (PST)
Message-ID: <20100226.020333.13570565.davem@davemloft.net>
References: <20100223191948.GE2673@psychotron.redhat.com>
	<20100226.014953.203661752.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54159
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751199Ab0BZKDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 05:03:15 -0500
In-Reply-To: <20100226.014953.203661752.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


100 EURO says you didn't compile test this.

@@ -975,7 +968,7 @@ static void do_set_multicast_list(struct net_device *dev)
 
   	if(dev->flags&IFF_PROMISC)
   		ei_outb_p(E8390_RXCONFIG | 0x18, e8390_base + EN0_RXCR);
-	else if(dev->flags&IFF_ALLMULTI || dev->mc_list)
+	else if (dev->flags & IFF_ALLMULTI || !netdev_mc_addr(dev))
   		ei_outb_p(E8390_RXCONFIG | 0x08, e8390_base + EN0_RXCR);
   	else
   		ei_outb_p(E8390_RXCONFIG, e8390_base + EN0_RXCR);

I'll fix it up, but you have to start getting proper build
coverage of your patches!

I really don't care how slow your netbook is, this case could have
been easily prevented.
