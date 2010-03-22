From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Mon, 22 Mar 2010 11:52:41 +0800
Message-ID: <20100322035241.GB14457@gondor.apana.org.au>
References: <20100322013257.GA14080@gondor.apana.org.au> <20100321.183656.173864141.davem@davemloft.net> <20100322014010.GA14182@gondor.apana.org.au> <20100321.201258.184825751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49875 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753865Ab0CVDwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 23:52:46 -0400
Content-Disposition: inline
In-Reply-To: <20100321.201258.184825751.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 21, 2010 at 08:12:58PM -0700, David Miller wrote:
> 
> Good point, I was misunderstanding how things work now and how
> that would change with your proposal.
> 
> Having multiple xfrm_dsts exist for an IPSEC route seems fine
> to me.

Thanks for the confirmation.

Timo, let's roll along with the per-cpu xfrm_dst approach.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
