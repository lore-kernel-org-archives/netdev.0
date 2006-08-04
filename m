From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Improve MTU estimation
Date: Fri, 4 Aug 2006 21:16:04 +1000
Message-ID: <20060804111604.GA25693@gondor.apana.org.au>
References: <44D30A48.4050403@trash.net> <44D312EF.8010202@trash.net> <20060804100121.GA17239@gondor.apana.org.au> <44D31CCE.7020301@trash.net> <20060804101345.GA17583@gondor.apana.org.au> <44D32B57.2000304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46354 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932359AbWHDLQG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 07:16:06 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44D32B57.2000304@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 04, 2006 at 01:11:19PM +0200, Patrick McHardy wrote:
>
> > Of course it gets hairier if you have ESP padding.  I'm not even sure
> > if the current code gets that right.
> 
> Unless I'm missing something, the padding caused by IP options
> is always less than the worst case that can happen anyway
> (max(block size, padlen)-1), so it can simply be ignored.

Are you talking about the ESP padding case, or transport mode in
general?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
