From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Add a XFRM_STATE_AF_UNSPEC flag to xfrm_usersa_info
Date: Thu, 10 Jul 2008 20:31:54 +0800
Message-ID: <20080710123154.GA25589@gondor.apana.org.au>
References: <20080710112901.GV9549@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36869 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753892AbYGJMcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 08:32:00 -0400
Content-Disposition: inline
In-Reply-To: <20080710112901.GV9549@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2008 at 01:29:01PM +0200, Steffen Klassert wrote:
> Add a XFRM_STATE_AF_UNSPEC flag to handle the AF_UNSPEC behavior
> for the selector family. Userspace applications can set this flag
> to leave the selector family of the xfrm_state unspecified.
> This can be used to to handle inter family tunnels if the
> selector is not set from userspace.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
