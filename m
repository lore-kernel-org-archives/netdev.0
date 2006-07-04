From: David Miller <davem@davemloft.net>
Subject: Re: [1/4] [IPV6]: Remove redundant length check on input
Date: Mon, 03 Jul 2006 19:44:06 -0700 (PDT)
Message-ID: <20060703.194406.23013279.davem@davemloft.net>
References: <78C9135A3D2ECE4B8162EBDCE82CAD7793A4C8@nekter>
	<20060701033939.GC29803@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ananda.Raju@neterion.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:39111
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751383AbWGDCnv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 22:43:51 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060701033939.GC29803@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 1 Jul 2006 13:39:39 +1000

> On Fri, Jun 30, 2006 at 07:44:49PM -0400, Ananda Raju wrote:
> > 
> > I tested the patch, and TSO over ipv6 is working fine. But TSO disable
> > not working for IPv6. 
> > 
> > I tried the from tree /pub/scm/linux/kernel/git/davem/net-2.6
> 
> I think we need some new ethtool helper functions that sets/clears both
> TSO/TSO6.

Do you really want to semantically seperate TSO and TSO6?

I would think that real users who want to disable TSO, wish
to do so unilaterally.

I think we should only add the TSO6 specific knob if we find
through experience that it often comes up that someone wants
to just disable ipv6 vs. ipv4 TSO.
