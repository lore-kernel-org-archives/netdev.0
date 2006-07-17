From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [NET]: Add missing UFO initialisations
Date: Mon, 17 Jul 2006 08:26:32 -0700
Message-ID: <20060717152632.GA4888@kroah.com>
References: <20060713091101.GA28651@gondor.apana.org.au> <20060713.220434.66181695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kroah.org ([69.55.234.183]:30374 "EHLO perch.kroah.org")
	by vger.kernel.org with ESMTP id S1750876AbWGQPxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 11:53:16 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060713.220434.66181695.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 13, 2006 at 10:04:34PM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 13 Jul 2006 19:11:01 +1000
> 
> > [NET]: Add missing UFO initialisations
> > 
> > This bug was unknowingly fixed the GSO patches (or rather, its effect was
> > unknown at the time).
> > 
> > Thanks to Marco Berizzi's persistence which is documented in the thread
> > "ipsec tunnel asymmetrical mtu", we now know that it can have highly
> > non-obvious symptoms.
> > 
> > What happens is that uninitialised uso_size fields can cause packets to
> > be incorrectly identified as UFO, which means that it does not get
> > fragmented even if it's over the MTU.
> > 
> > The fix is simple enough.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Queued to -stable, thanks.

greg k-h
