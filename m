From: David Miller <davem@davemloft.net>
Subject: Re: Deadlock with icmpv6fuzz
Date: Fri, 06 Feb 2009 03:05:48 -0800 (PST)
Message-ID: <20090206.030548.135134432.davem@davemloft.net>
References: <20090206092218.GB6645@gondor.apana.org.au>
	<20090206.012733.06998050.davem@davemloft.net>
	<20090206102710.GA7175@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, snakebyte@gmx.de, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56971
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751825AbZBFLFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 06:05:52 -0500
In-Reply-To: <20090206102710.GA7175@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 6 Feb 2009 21:27:10 +1100

> On Fri, Feb 06, 2009 at 01:27:33AM -0800, David Miller wrote:
> >
> > Actually, it's limited to sysctl_optmem_max :-)
> 
> Hiding the check in sock_kmalloc, clever :) In that case we don't
> have a problem.
> 
> But we should probably bring the check down to sysctl_optmem_max
> in ip6_flowlabel.c too since allocating 64K is still quite likely
> to fail and warn.

Good idea.
