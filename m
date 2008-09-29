From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Patch for tbench regression.
Date: Mon, 29 Sep 2008 13:40:52 +0800
Message-ID: <20080929054052.GA23600@gondor.apana.org.au>
References: <20080928211530.GA9341@2ka.mipt.ru> <20080929031244.GA22619@gondor.apana.org.au> <20080929053605.GA21663@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	Mel Gorman <mel@csn.ul.ie>, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@marvell.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43180 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752198AbYI2FlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 01:41:07 -0400
Content-Disposition: inline
In-Reply-To: <20080929053605.GA21663@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 09:36:06AM +0400, Evgeniy Polyakov wrote:
> On Mon, Sep 29, 2008 at 11:12:44AM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > Can you see if reverting the patch but using ethtool gives you the
> > same results?
> 
> Yes, I disabled gso and tso on vanilla 2.6.27-rc7 via ethtools and
> got the same results:

Are you using Xen FV or PV? What processor?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
