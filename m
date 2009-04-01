From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Re: skb_segment() questions
Date: Wed, 1 Apr 2009 17:53:52 +0800
Message-ID: <20090401095352.GB20003@gondor.apana.org.au>
References: <20090329020701.GA9983@gondor.apana.org.au> <20090401091801.GA5970@ff.dom.local> <20090401092457.GB19847@gondor.apana.org.au> <20090401095049.GB5970@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Huang <jamesclhuang@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33425 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752293AbZDAJyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 05:54:00 -0400
Content-Disposition: inline
In-Reply-To: <20090401095049.GB5970@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 01, 2009 at 09:50:50AM +0000, Jarek Poplawski wrote:
>
> I guess you mean non-linear skb with a header smaller than mtu? Well,
> if it's the most common case now, I agree.

The common case is the path stemming from the TCP stack, where
we always construct skb's with the entire payload in page frags,
and only the header is placed in skb->data.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
