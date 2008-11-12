From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SKB truesize bug
Date: Wed, 12 Nov 2008 09:37:44 +0800
Message-ID: <20081112013744.GB18072@gondor.apana.org.au>
References: <20081111092513.67c2a988@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56489 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751022AbYKLBhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 20:37:48 -0500
Content-Disposition: inline
In-Reply-To: <20081111092513.67c2a988@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2008 at 09:25:13AM -0800, Stephen Hemminger wrote:
> Is this bug fixed?  is it in the 2.6.26.8 kernel?

No and yes.

We need to fix up the truesize when resizing packets for IPsec
processing.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
