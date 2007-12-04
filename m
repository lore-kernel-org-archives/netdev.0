From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6 IPsec input
Date: Tue, 4 Dec 2007 16:51:06 +1100
Message-ID: <20071204055106.GA3889@gondor.apana.org.au>
References: <4754CBFF.3000308@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: usagi-core@linux-ipv6.org, netdev@vger.kernel.org
To: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1390 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751481AbXLDFvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 00:51:12 -0500
Content-Disposition: inline
In-Reply-To: <4754CBFF.3000308@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 04, 2007 at 12:39:43PM +0900, Kazunori MIYAZAWA wrote:
>
> I found that you directly pass the address family (AF_INET) to xfrm_state_lookup
> in xfrm_input.
> 
> I guess it may result the bug.
> 
> Is it correct?

Yes sorry, I didn't test IPv6.  Ironic because all this work is for
the benefit of IPv6 :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
