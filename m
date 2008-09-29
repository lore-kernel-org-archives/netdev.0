From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Patch for tbench regression.
Date: Mon, 29 Sep 2008 15:02:13 +0800
Message-ID: <20080929070213.GA24146@gondor.apana.org.au>
References: <20080928211530.GA9341@2ka.mipt.ru> <20080929031244.GA22619@gondor.apana.org.au> <20080929053605.GA21663@2ka.mipt.ru> <20080929054052.GA23600@gondor.apana.org.au> <20080929055203.GA3460@2ka.mipt.ru> <20080929064006.GA23967@gondor.apana.org.au> <20080929064518.GA10653@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	Mel Gorman <mel@csn.ul.ie>, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@marvell.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57341 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751152AbYI2HCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 03:02:21 -0400
Content-Disposition: inline
In-Reply-To: <20080929064518.GA10653@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 10:45:18AM +0400, Evgeniy Polyakov wrote:
>
> $ cat /proc/interrupts 
> CPU0       
> 0:         71    XT-PIC-XT        timer
> 1:          8    XT-PIC-XT        i8042
> 2:          0    XT-PIC-XT        cascade
> 5:      17606    XT-PIC-XT        eth0
> 12:          5    XT-PIC-XT        i8042
> 14:       6925    XT-PIC-XT        ide0
> 15:        141    XT-PIC-XT        ide1
> NMI:          0   Non-maskable interrupts
> LOC:    1190668   Local timer interrupts
> RES:          0   Rescheduling interrupts
> CAL:          0   function call interrupts
> TLB:          0   TLB shootdowns
> TRM:          0   Thermal event interrupts
> SPU:          0   Spurious interrupts
> ERR:          0
> MIS:          0

OK you're on FV as well.  I'll try it on my laptaop next.

> Shouldn't tests over loopback be like lots of memcpy in the userspace
> process? Usually its performance is close enough to the kernel's range,
> despite very different sizes of TLB entries.

Where it may differ is when you have context switches.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
