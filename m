From: "David S. Miller" <davem@davemloft.net>
Subject: Re: BCM5704 performance questions.
Date: Fri, 10 Jun 2005 15:43:32 -0700 (PDT)
Message-ID: <20050610.154332.122616684.davem@davemloft.net>
References: <42AA016C.9050801@candelatech.com>
	<1118438203.5294.7.camel@rh4>
	<42AA15B7.8050407@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <42AA15B7.8050407@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 10 Jun 2005 15:35:35 -0700

> Michael Chan wrote:
> > On Fri, 2005-06-10 at 14:09 -0700, Ben Greear wrote:
> 
> >>I commented out the code and ran the pktgen test again.  It may be a small
> >>bit better, but not much:  770Mbps in one direction, 750Mbps in the other.
> >>
> 
> > The latest tg3 driver will print out the dma_rwctrl at probe time. Can
> > you check the value to make sure ONE_DMA is disabled? Bit 14 sets
> > ONE_DMA.
> 
> I don't see any printout in /var/log/messages that looks like it
> relates to the dma_rwctrl.  I'm using the driver in 2.6.11..maybe
> it is not recent enough to print this information out?

Yes, your driver is too old.  The one in Linus's current GIT
tree has this, along with many other enhancements.
