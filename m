From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] Avoid gettimeofday when not needed
Date: 31 Mar 2004 15:54:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040331135449.GB62402@colin2.muc.de>
References: <200403311201.i2VC13D19579@zero.aec.at> <Pine.LNX.4.58.0403311552070.19615@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Wed, 31 Mar 2004 15:54:49 +0200
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0403311552070.19615@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I suspect this breaks proxy arp/ndisc!
> 
> The arp/ndisc requests are queued up for a random time before being
> processed by the proxy. Check out pneigh_enqueue() in net/core/neighbour.c
> for details. The skb->stamp.tv_sec check was used to separate the locally
> re-fed requests from ones received from the net.

Ok, thanks for clarifying this. I guessed the intention wrong then.

A better way may be to just add a new skb flag for this that is managed
by the arp code? Comments?

-Andi
