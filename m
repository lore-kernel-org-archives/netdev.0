From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Thu, 1 May 2008 18:38:54 +0800
Message-ID: <20080501103854.GA7285@gondor.apana.org.au>
References: <20080430.145820.50450486.davem@davemloft.net> <E1JrVtK-0001pb-00@gondolin.me.apana.org.au> <20080501.033414.132094744.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, kmansley@solarflare.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58798 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752595AbYEAKjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 06:39:06 -0400
Content-Disposition: inline
In-Reply-To: <20080501.033414.132094744.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 01, 2008 at 03:34:14AM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 01 May 2008 18:19:54 +0800
> 
> > This patch completely breaks forwarding of GSO packets in a
> > virtualised environment where we explicitly want to forward
> > them as is to reduce per-packet overhead.  So if LRO is causing
> > problems then I suggest we find a better way around that that
> > does not penalise all forms of GSO.
> 
> I assume you mean forwarding via a bridge?

Not necessarily.  For example we could be forwarding in a guest
that's acting as a firewall appliance for other guests.

> I think we'll need to add a device attribute for what
> you want.

I still don't understand why we can't forward LRO packets.  It
should be no different to forwarding GSO packets if it's properly
constructed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
