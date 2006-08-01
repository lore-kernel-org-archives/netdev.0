From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Wed, 2 Aug 2006 08:04:27 +1000
Message-ID: <20060801220427.GA11025@gondor.apana.org.au>
References: <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <44CE4DCA.8000609@trash.net> <20060801.000059.57444384.davem@davemloft.net> <20060801153405.GA6259@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60685 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751214AbWHAWEj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 18:04:39 -0400
To: Phil Oester <kernel@linuxace.com>
Content-Disposition: inline
In-Reply-To: <20060801153405.GA6259@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 08:34:05AM -0700, Phil Oester wrote:
> On Tue, Aug 01, 2006 at 12:00:59AM -0700, David Miller wrote:
> >     What we have now is infinitely better than the past,
> >     wherein all TSO packets were dropped due to corrupt
> >     checksums as soon at the NAT module was loaded.
> 
> At what point did this problem begin?  2.6.18-rc or prior?

Since we had TSO.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
