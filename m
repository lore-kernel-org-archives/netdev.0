From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Sat, 5 Aug 2006 17:59:47 +1000
Message-ID: <20060805075946.GA20167@gondor.apana.org.au>
References: <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <44CE4DCA.8000609@trash.net> <20060801122916.GA6177@gondor.apana.org.au> <44D1C205.4010509@trash.net> <20060803093309.GB8808@gondor.apana.org.au> <44D1C471.2050503@trash.net> <20060803095703.GA9082@gondor.apana.org.au> <44D4452F.5090406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:16395 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1422758AbWHEH7x
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 03:59:53 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44D4452F.5090406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick:

On Sat, Aug 05, 2006 at 09:13:51AM +0200, Patrick McHardy wrote:
> 
> I've made the other changes you suggested, but removing the tildes here
> didn't work, so I left them in. I'll send the new patches in a few
> minutes.

You're right of course.  I was simply confused.  The partial checksum
happens to be the negation of the complete checksum for the pseudo-header.

All of your patches look good to me.  Thanks for fixing these bugs!

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
