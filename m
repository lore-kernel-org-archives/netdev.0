From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Deadlock with icmpv6fuzz
Date: Fri, 6 Feb 2009 21:27:10 +1100
Message-ID: <20090206102710.GA7175@gondor.apana.org.au>
References: <20090206085406.GA6540@gondor.apana.org.au> <20090206.010559.157790037.davem@davemloft.net> <20090206092218.GB6645@gondor.apana.org.au> <20090206.012733.06998050.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, snakebyte@gmx.de, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60516 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753939AbZBFK1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 05:27:21 -0500
Content-Disposition: inline
In-Reply-To: <20090206.012733.06998050.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 06, 2009 at 01:27:33AM -0800, David Miller wrote:
>
> Actually, it's limited to sysctl_optmem_max :-)

Hiding the check in sock_kmalloc, clever :) In that case we don't
have a problem.

But we should probably bring the check down to sysctl_optmem_max
in ip6_flowlabel.c too since allocating 64K is still quite likely
to fail and warn.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
