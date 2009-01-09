From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Fri, 9 Jan 2009 14:48:04 +1100
Message-ID: <20090109034804.GA11741@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, bhutchings@solarflare.com,
	rick.jones2@hp.com, davem@davemloft.net, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53842 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752221AbZAIDsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 22:48:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> The person who added this should have used the new flags interface, and 
> added ETH_FLAG_GRO right next to the pre-existing ETH_FLAG_LRO.
> 
> It is incorrect to add new ioctls just to toggle a boolean value.

Well you missed my earlier explanation.  GRO is a stack flag,
it's not something we want the device drivers to touch at all.

The generic flags interface appears to be designed for flags
that the device driver directly controls, such as LRO.  That's
why it is inappropriate for GRO, which like GSO is entirely done
in software.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
