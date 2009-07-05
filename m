From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: flow director and packet ordering
Date: Sun, 5 Jul 2009 12:19:55 +0800
Message-ID: <20090705041955.GA7892@gondor.apana.org.au>
References: <20090616.023132.194401812.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33167 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750754AbZGEETz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 00:19:55 -0400
Content-Disposition: inline
In-Reply-To: <20090616.023132.194401812.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> In the meantime you cannot switch the RX queue mapping without
> introducing reordering.
> 
> So my original fears and doubts still stand :-)

Methinks this whole idea is doomed.  The fact is as long as there
are more sockets than queues, then you can have two sockets pull
the same queue in different directions and there's nothing you can
do about that.

That's my bit of uncertainty for you :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
