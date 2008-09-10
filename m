From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Wed, 10 Sep 2008 13:23:04 +1000
Message-ID: <20080910032304.GA28580@gondor.apana.org.au>
References: <20080903055041.GA8547@gondor.apana.org.au> <20080909.200400.96645840.davem@davemloft.net> <20080910031559.GA27430@gondor.apana.org.au> <20080909.202215.197131148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48118 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751949AbYIJDXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 23:23:10 -0400
Content-Disposition: inline
In-Reply-To: <20080909.202215.197131148.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 09, 2008 at 08:22:15PM -0700, David Miller wrote:
>
> > What could be done though is to remove x->all and restore the
> > original walking by hashing.  This would eliminate a list node
> > from xfrm_state, and would also restore the original dump ordering.
> 
> Yes I remember you mentioning that.
> 
> If you're too busy I can try to spin this idea into a patch.

That would be very much appreciated.  Thanks Dave!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
