From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC]: Don't warn if high-order hash resize fails
Date: Mon, 14 May 2007 17:27:55 +1000
Message-ID: <20070514072755.GB24412@gondor.apana.org.au>
References: <20070514054837.GA18879@gondor.apana.org.au> <20070513.233635.28398106.davem@davemloft.net> <20070514070733.GA23173@gondor.apana.org.au> <20070514072657.GA24412@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1469 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757377AbXENH15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 03:27:57 -0400
Content-Disposition: inline
In-Reply-To: <20070514072657.GA24412@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2007 at 05:26:57PM +1000, Herbert Xu wrote:
> On Mon, May 14, 2007 at 05:07:33PM +1000, Herbert Xu wrote:
> > 
> > Good point.  A bit of dd-ing shows that I've got a negative value
> > in xfrm_policy_count[0] (0xfffffff6).
> 
> In fact the other two directions are bogus too, OUT says 10 and FWD
> says 5.  The actual values are IN == 2, OUT == 2, FWD == 1.  The
> socket policy counts are correct though.

In fact that's a clue.  If you add them all up they come out at the
same value.  So we're getting the directions mixed up...

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
