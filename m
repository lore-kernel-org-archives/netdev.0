From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [0/7] IPsec: Preparatory patcheds for async crypto on output
Date: Mon, 8 Oct 2007 16:20:40 +0400
Message-ID: <20071008122034.GA23718@2ka.mipt.ru>
References: <20071008112818.GA3010@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59857 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753999AbXJHMVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2007 08:21:30 -0400
Content-Disposition: inline
In-Reply-To: <20071008112818.GA3010@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 08, 2007 at 07:28:18PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> Here is a bunch of patches paving the way for removal of the
> state spin lock on the output path so that we can let the crypto
> complete asynchronously.

Hi Herbert.

This looks great. I especially like xfrm output path generalization and
xfrm_skb_cb structure introduction (acrypto allocated a special
structure from slab for each packet).
Do you expect to complete full async processing before 2.6.24 and, Dave,
is there any chance it can be accepted for upcoming release?

-- 
	Evgeniy Polyakov
