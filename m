From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: net: generic netdev_ioaddr
Date: Fri, 29 Oct 2004 21:18:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3y8hpbaf9.fsf@defiant.pm.waw.pl>
References: <1099044244.9566.0.camel@localhost>
	<20041029131607.GU24336@parcelfarce.linux.theplanet.co.uk>
	<courier.418290EC.00002E85@courier.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@parcelfarce.linux.theplanet.co.uk>, davem@davemloft.net,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Pekka J Enberg" <penberg@cs.helsinki.fi>
In-Reply-To: <courier.418290EC.00002E85@courier.cs.helsinki.fi> (Pekka J.
 Enberg's message of "Fri, 29 Oct 2004 21:50:20 +0300")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"Pekka J Enberg" <penberg@cs.helsinki.fi> writes:

> Yup, I thought about that after I sent the patch. However, as it
> stands now, many network drivers use netdev->base_addr for just that.
> Perhaps it should be nuked completely instead?

I thinks so. With ifmap, SIOCSIFMAP, ifr_map, mem_end etc.,
irq, if_port, dma.
-- 
Krzysztof Halasa
