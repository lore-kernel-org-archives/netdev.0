From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Wed, 10 Sep 2008 15:46:25 +1000
Message-ID: <20080910054625.GA26821@gondor.apana.org.au>
References: <20080910040107.GA29695@gondor.apana.org.au> <20080909.210654.159776216.davem@davemloft.net> <48C7581C.1080800@iki.fi> <20080909.222330.172681301.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39299 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750859AbYIJFqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 01:46:31 -0400
Content-Disposition: inline
In-Reply-To: <20080909.222330.172681301.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 09, 2008 at 10:23:30PM -0700, David Miller wrote:
> 
> That's a good point, the hash resizing case.
> 
> If the hash grows, we'll see some entries again.
> 
> If it shrinks, we might skip some instead, which is very undesirable.
> 
> Actually, thinking about it some more, both possibilities (skipping
> and dups) seem to be possible in both situations (growing and
> shrinking).
> 
> Ehm... I think we should put this patch and idea aside for a little bit.
> :-)

Yeah the hash resizing thing really kills this approach.  In fact
it seems that the original walker was written before resizing was
added.

I definitely agree that ordering isn't as important as showing the
entries reliably.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
