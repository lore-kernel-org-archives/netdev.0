From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Patch for tbench regression.
Date: Mon, 29 Sep 2008 11:11:19 +0400
Message-ID: <20080929071119.GA29076@2ka.mipt.ru>
References: <20080928211530.GA9341@2ka.mipt.ru> <20080929031244.GA22619@gondor.apana.org.au> <20080929053605.GA21663@2ka.mipt.ru> <20080929054052.GA23600@gondor.apana.org.au> <20080929055203.GA3460@2ka.mipt.ru> <20080929064006.GA23967@gondor.apana.org.au> <20080929064518.GA10653@2ka.mipt.ru> <20080929070213.GA24146@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	Mel Gorman <mel@csn.ul.ie>, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@marvell.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:39189 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751734AbYI2HM7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2008 03:12:59 -0400
Content-Disposition: inline
In-Reply-To: <20080929070213.GA24146@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 03:02:13PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > $ cat /proc/interrupts 
> > CPU0       
> > 0:         71    XT-PIC-XT        timer
> > 1:          8    XT-PIC-XT        i8042
> > 2:          0    XT-PIC-XT        cascade
> > 5:      17606    XT-PIC-XT        eth0
> > 12:          5    XT-PIC-XT        i8042
> > 14:       6925    XT-PIC-XT        ide0
> > 15:        141    XT-PIC-XT        ide1
> > NMI:          0   Non-maskable interrupts
> > LOC:    1190668   Local timer interrupts
> > RES:          0   Rescheduling interrupts
> > CAL:          0   function call interrupts
> > TLB:          0   TLB shootdowns
> > TRM:          0   Thermal event interrupts
> > SPU:          0   Spurious interrupts
> > ERR:          0
> > MIS:          0
> 
> OK you're on FV as well.  I'll try it on my laptaop next.

How did you find that? :)

> > Shouldn't tests over loopback be like lots of memcpy in the userspace
> > process? Usually its performance is close enough to the kernel's range,
> > despite very different sizes of TLB entries.
> 
> Where it may differ is when you have context switches.

Yes, of course, even single empty syscall may potentially force process
the be scheduled away, bit still performance will not be with 24/190
ratio... Weird.

-- 
	Evgeniy Polyakov
