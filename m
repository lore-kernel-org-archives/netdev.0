From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: flow director and packet ordering
Date: Mon, 6 Jul 2009 10:55:14 +0800
Message-ID: <20090706025514.GA15764@gondor.apana.org.au>
References: <20090705041955.GA7892@gondor.apana.org.au> <20090705.155354.85683961.davem@davemloft.net> <20090706011051.GB15156@gondor.apana.org.au> <20090705.185956.121092946.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43170 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753204AbZGFCzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 22:55:13 -0400
Content-Disposition: inline
In-Reply-To: <20090705.185956.121092946.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 05, 2009 at 06:59:56PM -0700, David Miller wrote:
>
> I personally assume that a master process that accepts connections
> and then hands them off down to worker threads is quite common.

In this scenario I think it might be better to determine which
worker thread to hand the socket to based on the current RX queue
assignment.  This way you won't have to worry about what limit
the hardware has in terms of how many flows it can assign.

Of course if you can't modify the app then you'd have to rely on
hardware assignment.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
