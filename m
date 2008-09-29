From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Patch for tbench regression.
Date: Mon, 29 Sep 2008 14:40:06 +0800
Message-ID: <20080929064006.GA23967@gondor.apana.org.au>
References: <20080928211530.GA9341@2ka.mipt.ru> <20080929031244.GA22619@gondor.apana.org.au> <20080929053605.GA21663@2ka.mipt.ru> <20080929054052.GA23600@gondor.apana.org.au> <20080929055203.GA3460@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	Mel Gorman <mel@csn.ul.ie>, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@marvell.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57928 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750963AbYI2GkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 02:40:14 -0400
Content-Disposition: inline
In-Reply-To: <20080929055203.GA3460@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 09:52:03AM +0400, Evgeniy Polyakov wrote:
> On Mon, Sep 29, 2008 at 01:40:52PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > Are you using Xen FV or PV? What processor?
> 
> Can I determine that within guest?

cat /proc/interrupts

should do the trick

> Actually it is a bit strange, if full or paravirtualization affects how
> loopback network works, I thought it should only affect communication
> between domains?

It also affects the MMU and other things.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
