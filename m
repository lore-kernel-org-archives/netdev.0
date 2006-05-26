From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 6610] New: dummy interface broadcast destination hardware address is not ff:ff:ff:ff:ff:ff
Date: Fri, 26 May 2006 10:43:24 +1000
Message-ID: <20060526004324.GA762@gondor.apana.org.au>
References: <20060523.165343.104035136.davem@davemloft.net> <E1Fihtm-0003dO-00@gondolin.me.apana.org.au> <20060525.151602.102574435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:16906 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965222AbWEZAoZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 20:44:25 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060525.151602.102574435.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 25, 2006 at 03:16:02PM -0700, David Miller wrote:
> 
> Perhaps RTN_BROADCAST should take precedence over IFF_NOARP
> (but not IFF_LOOPBACK)?  I'm talking about the code in
> net/ipv4/arp.c that causes this behavior.

Sure, I don't see any harm in that.

However, I'm curious as to the purpose of all this.  What application
is there for sending broadcasts through a dummy device with the
Ethernet broadcast address?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
