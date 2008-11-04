From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Have af-specific init_tempsel() initialize family
	field of temporary selector
Date: Tue, 4 Nov 2008 19:52:28 +0800
Message-ID: <20081104115228.GC11049@gondor.apana.org.au>
References: <87hc6npz4c.fsf@natisbad.org> <20081104112424.GB11049@gondor.apana.org.au> <87ljvziuhn.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Andreas Steffen <andreas.steffen@strongswan.org>,
	Martin Willi <martin@strongswan.org>,
	Kazunori MIYAZAWA <kazunori@miyazawa.org>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56914 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750987AbYKDLwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 06:52:35 -0500
Content-Disposition: inline
In-Reply-To: <87ljvziuhn.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 04, 2008 at 12:46:44PM +0100, Arnaud Ebalard wrote:
>
> Sorry Herbert, my initial comment was misleading: the family is not set
> in the selectors provided in the *XFRM_MSG_ACQUIRE*, which is not MIPv6 
> related. I could check again, but I think the patch below will impact
> all native key managers. Or did I miss something and there is a specific
> reason why MIPv6 folks may be impacted?

Indeed, you're right.  I was thinking of SA creation.

> >> Reported-by: Andreas Steffen <andreas.steffen@strongswan.org>
> >> Signed-off-by: Arnaud Ebalard <arno@natisbad.org>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
