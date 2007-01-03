From: Horms <horms@verge.net.au>
Subject: Re: [PATCH] [IPVS] replace if .. goto with while
Date: Wed, 3 Jan 2007 22:37:51 +0900
Message-ID: <20070103133741.GA2570@verge.net.au>
References: <20061218031110.GA32036@verge.net.au> <20070102.003839.08324311.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg,
	ratz@drugphish.ch, jmack@wm7d.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:55101 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790AbXACN7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 08:59:03 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20070102.003839.08324311.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 02, 2007 at 12:38:39AM -0800, David Miller wrote:
> From: Horms <horms@verge.net.au>
> Date: Mon, 18 Dec 2006 12:11:11 +0900
> 
> > I guess that this code used to be more complex, but replacing
> > the goto with a while seems to make things a bit more readable.
> > Or in other words, two fairly gratuitous goto are removed.
> > 
> > On a related note, I wonder if there should be a limit to how
> > many times it tries.
> > 
> > Signed-Off-By: Simon Horman <horms@verge.net.au>
> 
> Yes, there should be, something like a limit of one. :-)
> 
> There is no reason to loop on something like this, just
> return a failure immediately if creating the kernel thread
> fails.

Will do.

> As a side note, if it's easy you might want to convert this
> over the the include/linux/kthread.h interfaces.  I just did
> this for pktgen tonight and it cleaned a lot of stuff up.

Thanks, I will look into it.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

