From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 6610] New: dummy interface broadcast
 destination hardware address is not ff:ff:ff:ff:ff:ff
Date: Thu, 25 May 2006 18:18:13 -0700 (PDT)
Message-ID: <20060525.181813.66176551.davem@davemloft.net>
References: <E1Fihtm-0003dO-00@gondolin.me.apana.org.au>
	<20060525.151602.102574435.davem@davemloft.net>
	<20060526004324.GA762@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35538
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1030208AbWEZBSK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 21:18:10 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060526004324.GA762@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 26 May 2006 10:43:24 +1000

> On Thu, May 25, 2006 at 03:16:02PM -0700, David Miller wrote:
> > 
> > Perhaps RTN_BROADCAST should take precedence over IFF_NOARP
> > (but not IFF_LOOPBACK)?  I'm talking about the code in
> > net/ipv4/arp.c that causes this behavior.
> 
> Sure, I don't see any harm in that.
> 
> However, I'm curious as to the purpose of all this.  What application
> is there for sending broadcasts through a dummy device with the
> Ethernet broadcast address?

Good point.  dummy is just a black hole to point routes to
while your real connection is down.

Running tcpdump on it and having any kind of expectations
about broadcast addresses and whatnot is pointless.
