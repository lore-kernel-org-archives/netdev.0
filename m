From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Xen-devel] kernel BUG at net/core/dev.c:1133!
Date: Sat, 8 Jul 2006 12:03:42 +1000
Message-ID: <20060708020342.GA9746@gondor.apana.org.au>
References: <E1FyrUg-0003FA-00@gondolin.me.apana.org.au> <907625E08839C4409CE5768403633E0BA7FD7F@sefsexmb1.amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39690 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932374AbWGHCD7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 22:03:59 -0400
To: "Petersson, Mats" <Mats.Petersson@amd.com>
Content-Disposition: inline
In-Reply-To: <907625E08839C4409CE5768403633E0BA7FD7F@sefsexmb1.amd.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 07, 2006 at 05:03:36PM +0200, Petersson, Mats wrote:
> 
> So, nothing going on there... I certainly haven't got NAT on my machine,
> as my machine is within the AMD network, and doesn't need NAT. AMD
> probably uses NAT as part of it's external communications, but I doubt
> it's used at all internally. 

Actually, just having it loaded is enough to break TSO.  So for all this
time anyone who had ip_nat loaded were silently corrupting all their TSO
checksums!

I'll send a patch soon once I've tested it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
