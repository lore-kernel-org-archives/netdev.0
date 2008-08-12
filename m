From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: csum offload and af_packet
Date: Wed, 13 Aug 2008 09:37:53 +1000
Message-ID: <20080812233753.GA29155@gondor.apana.org.au>
References: <E1KSU3v-00037r-00@gondolin.me.apana.org.au> <20080811.175154.168708843.davem@davemloft.net> <20080812005839.GC18547@gondor.apana.org.au> <200808121817.19662.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rusty@rustcorp.com.au,
	anthony@codemonkey.ws, netdev@vger.kernel.org
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46738 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752322AbYHLXiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 19:38:07 -0400
Content-Disposition: inline
In-Reply-To: <200808121817.19662.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 06:17:19PM +0200, Ingo Oeser wrote:
>
> Are you talking about modifying the KVM client image?
> There may be reasons, why this is impossible or at least highly undesired.
> 
> Before virtualisation developers of embedded stuff need to seal away
> their whole machines for their development and test environment 
> together with sample hardware.
> 
> Now using virtualisation they can at least virtualize their development
> and test environment, save lots of cost and not risking that their sealed 
> away hardware will not start again, when they need to fix a critical bug 
> 10-20 years later.

Oh I totally agree that there are lots of scenarios where you
want to have an unmolested guest image.  My point was that if
you're going to touch the guest kernel anyway you might as well
fix the guest user-space instead.

This is also why I've argued that the default should be to disable
TX checksums until the guest enables it so that old guests that
know nothing about this can continue to work.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
