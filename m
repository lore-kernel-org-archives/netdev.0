From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 0/5] IPsec parallelization
Date: Tue, 2 Dec 2008 16:53:25 +0800
Message-ID: <20081202085325.GA30353@gondor.apana.org.au>
References: <20081201071614.GP476@secunet.com> <20081201084902.GA19904@gondor.apana.org.au> <20081201.022929.253639406.davem@davemloft.net> <20081201111501.GA20650@gondor.apana.org.au> <20081202075804.GD13998@secunet.com> <20081202081948.GA30063@gondor.apana.org.au> <20081202084419.GF13998@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54494 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751016AbYLBIxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 03:53:30 -0500
Content-Disposition: inline
In-Reply-To: <20081202084419.GF13998@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 02, 2008 at 09:44:19AM +0100, Steffen Klassert wrote:
>
> > 3) The same mechanism can benefit other crypto users such as
> > disk encryption.
> 
> The padata stuff is generic, so it can be used even for disk
> encryption or for anything else that should run in parallel but
> needs a certain order at a given point.

The padata stuff might be great, but does that mean that we really
want to reimplement exactly the same logic in two different places
when we can do it just once in the crypto layer (which could also
use padata as you suggested)?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
