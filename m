From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] macvlan: Move broadcasts into a work queue
Date: Fri, 11 Apr 2014 09:59:06 +0800
Message-ID: <20140411015906.GB31251@gondor.apana.org.au>
References: <20140407142334.GA28814@gondor.apana.org.au>
 <53442868.3090701@candelatech.com>
 <20140408172349.GA7147@gondor.apana.org.au>
 <20140410.214023.849284639345029049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greearb@candelatech.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:38261 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754064AbaDKB7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 21:59:12 -0400
Content-Disposition: inline
In-Reply-To: <20140410.214023.849284639345029049.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 10, 2014 at 09:40:23PM -0400, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 9 Apr 2014 01:23:49 +0800
> 
> > On Tue, Apr 08, 2014 at 09:48:40AM -0700, Ben Greear wrote:
> >> 
> >> At least for ARPs, maybe we could inspect the packet and only
> >> deliver to interfaces configured with the MAC that is being
> >> ARPed for (or ones that are in promisc)?
> > 
> > Yes this would definitely be a great optimisation.
> 
> Yes and you can use the direct rather than the workqueue path.

This would be a worthy optimisation for bridge.c too.  In fact,
I wonder if it would be possible to share some of the broadcast/
multicast logic between macvlan and bridge.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
