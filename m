From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 03/06] MLSXFRM: Add security sid to sock
Date: Wed, 21 Jun 2006 14:35:02 +1000
Message-ID: <20060621043502.GA899@gondor.apana.org.au>
References: <36282A1733C57546BE392885C06185920132401F@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48912 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932278AbWFUEfF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 00:35:05 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Content-Disposition: inline
In-Reply-To: <36282A1733C57546BE392885C06185920132401F@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 20, 2006 at 08:50:55PM -0400, Venkat Yekkirala wrote:
>
> Nope. It would actually overwrite the pointer, so we put it away before
> memcpy
> and set it back after memcpy.

Right, I misread it as sptr = osk->sk_security.  Still, it'd be nice to
optimise it away for the !SECURITY case.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
