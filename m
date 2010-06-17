From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 8/8] bridge: Fix netpoll support
Date: Thu, 17 Jun 2010 20:55:26 +1000
Message-ID: <20100617105526.GA1440@gondor.apana.org.au>
References: <20100611021142.GA24490@gondor.apana.org.au> <E1OMtjm-0006PK-D6@gondolin.me.apana.org.au> <4C1755C1.3060804@redhat.com> <20100617103819.GA1252@gondor.apana.org.au> <4C19FF98.5080105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Matt Mackall <mpm@selenic.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:56677 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750946Ab0FQKze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jun 2010 06:55:34 -0400
Content-Disposition: inline
In-Reply-To: <4C19FF98.5080105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 17, 2010 at 06:57:28PM +0800, Cong Wang wrote:
>
> Hmm, I get it now. So this helps to fix problem 3)?

Yes, by allocating real netpoll structures for each device that
we're polling, instead of sharing a single one amongst all of
them.

This is also the basis of the solution of the use-after-free bug.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
