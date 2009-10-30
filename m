From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] sky2: set carrier off in probe
Date: Fri, 30 Oct 2009 15:13:16 -0400
Message-ID: <20091030191316.GA10029@gondor.apana.org.au>
References: <20091030155420.GA8345@gondor.apana.org.au> <20091030.111027.234994529.davem@davemloft.net> <20091030181632.GA9530@gondor.apana.org.au> <20091030.112051.20510373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bphilips@suse.de, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33259 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757339AbZJ3TNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 15:13:19 -0400
Content-Disposition: inline
In-Reply-To: <20091030.112051.20510373.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2009 at 11:20:51AM -0700, David Miller wrote:
>
> Since many drivers (especially virtual software ones) do not manage
> carrier state and therefore that's why we start in state carrier on.
> 
> We've had this discussion a few times before, most recently with
> Rusty wrt. virtio :-)

You're right, modifying the driver is the best way.  Oh well,
at least it's easy to find them by searching for netif_carrier :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
