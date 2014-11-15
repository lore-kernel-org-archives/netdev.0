From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/4] rhashtable: Add parent argument to mutex_is_held
Date: Sat, 15 Nov 2014 11:25:12 +0800
Message-ID: <20141115032512.GA19299@gondor.apana.org.au>
References: <20141113101025.GA3728@gondor.apana.org.au>
 <E1XorN4-0000zn-0H@gondolin.me.apana.org.au>
 <20141113103723.GO19157@casper.infradead.org>
 <20141113103834.GA4024@gondor.apana.org.au>
 <20141113104124.GA24379@casper.infradead.org>
 <20141113104343.GA4112@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44038 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934378AbaKODZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 22:25:19 -0500
Content-Disposition: inline
In-Reply-To: <20141113104343.GA4112@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 13, 2014 at 06:43:43PM +0800, Herbert Xu wrote:
> On Thu, Nov 13, 2014 at 10:41:24AM +0000, Thomas Graf wrote:
> >
> > Never mind. You did fix it. I looked at the wrong patch.
> 
> OK.  Now comes the fun part of shoehorning the xfrm_policy bydst
> hash into rhashtable :)

Thomas, it appears that rhashtable as it stands cannot handle
changing the random seed because of the way it constructs the
new hash table without degrading into a linked list.  Is there
something I'm missing?

FWIW my hashtable in net/bridge/br_multicast.c handles rehashing
correctly.  Any objections to me converting rhashtable to use my
scheme instead?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
