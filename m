From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Fix inter family IPsec tunnel handling again
Date: Thu, 3 Jul 2008 17:53:12 +0800
Message-ID: <20080703095312.GA28238@gondor.apana.org.au>
References: <20080703085542.GJ9549@secunet.com> <20080703090522.GB27923@gondor.apana.org.au> <20080703091836.GK9549@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58973 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760953AbYGCNzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 09:55:13 -0400
Content-Disposition: inline
In-Reply-To: <20080703091836.GK9549@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 03, 2008 at 11:18:36AM +0200, Steffen Klassert wrote:
>
> Well, I added the ifdef because it was there in the 2.6.24 code,
> I could remove it and resend if you agree with the rest of the patch.

You missed my point.  The fact that you're testing for IPv6 at all
is the bit that requires explanation.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
