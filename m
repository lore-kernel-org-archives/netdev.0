From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Unnecessary check in __sk_stream_mem_reclaim?
Date: Wed, 12 Jul 2006 14:30:00 +1000
Message-ID: <20060712043000.GB12535@gondor.apana.org.au>
References: <5640c7e00607111942jc0ef6cdyc0466dc0cfd5a00b@mail.gmail.com> <E1G0V93-00037K-00@gondolin.me.apana.org.au> <5640c7e00607112017v326ebb4qcdd0a10a79df2de2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50438 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932198AbWGLEaD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 00:30:03 -0400
To: Ian McDonald <ian.mcdonald@jandi.co.nz>
Content-Disposition: inline
In-Reply-To: <5640c7e00607112017v326ebb4qcdd0a10a79df2de2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 12, 2006 at 03:17:43PM +1200, Ian McDonald wrote:
>
> I'm not saying the check is unneeded - just saying doing it twice is 
> unneeded.

Right, got you this time.

I don't think we need to worry about people who use __sk_stream_mem_reclaim
when there is a perfectly good sk_stream_mem_reclaim around.

Besides, this function has only been exported since 2004 so it's highly
unlikely for there to be stuff out there using it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
