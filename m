From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Fri, 26 Dec 2008 13:38:28 +1100
Message-ID: <20081226023828.GA12266@gondor.apana.org.au>
References: <Pine.LNX.4.64.0812182040120.11995@wrl-59.cs.helsinki.fi> <20081225.171146.208898156.davem@davemloft.net> <20081226014739.GA11880@gondor.apana.org.au> <20081225.180051.116331110.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilpo.jarvinen@helsinki.fi, kuznet@ms2.inr.ac.ru, ptesarik@suse.cz,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45912 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752187AbYLZCiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 21:38:46 -0500
Content-Disposition: inline
In-Reply-To: <20081225.180051.116331110.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 25, 2008 at 06:00:51PM -0800, David Miller wrote:
> 
> So it all hinges on how the receiver updates his URG pointer.  This is
> what legitimizes a sender advertising a changing URG pointer.

Pretty much.

> So it works, but it isn't the nicest thing in the world :-)

It would've been nice and simple had the original implementors
strictly followed RFC793 and done the out-of-band notifications
instead of coming up with their fanciful notions of out-of-band
data :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
