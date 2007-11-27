From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/1][ATM]: [he] initialize lock and tasklet earlier
Date: Tue, 27 Nov 2007 11:04:16 +0800
Message-ID: <20071127030416.GA1502@gondor.apana.org.au>
References: <200711261633.lAQGXWvr027742@cmf.nrl.navy.mil> <20071127030341.GA1444@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1357 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753954AbXK0DET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 22:04:19 -0500
Content-Disposition: inline
In-Reply-To: <20071127030341.GA1444@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2007 at 11:03:41AM +0800, Herbert Xu wrote:
> On Mon, Nov 26, 2007 at 04:33:31PM +0000, chas williams - CONTRACTOR wrote:
> > if you are lucky (unlucky?) enough to have shared interrupts, the
> > interrupt handler can be called before the tasklet and lock are ready
> > for use.
> 
> Patch applied.  Thanks Chas!

Oh please don't forget to add a Signed-off-by header next time.
I've added it for you this time.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
