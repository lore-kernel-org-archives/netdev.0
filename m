From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/5] xfrm: Traffic Flow Confidentiality for IPv4 ESP
Date: Mon, 6 Dec 2010 23:22:54 +0800
Message-ID: <20101206152254.GA29030@gondor.apana.org.au>
References: <1291132155-31277-1-git-send-email-martin@strongswan.org> <1291132155-31277-4-git-send-email-martin@strongswan.org> <20101203073403.GA2292@gondor.apana.org.au> <1291365175.1997.34.camel@martin> <20101203083908.GA2940@gondor.apana.org.au> <1291648225.1954.179.camel@martin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Martin Willi <martin@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:60072 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837Ab0LFPW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 10:22:56 -0500
Content-Disposition: inline
In-Reply-To: <1291648225.1954.179.camel@martin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 06, 2010 at 04:10:25PM +0100, Martin Willi wrote:
> > 
> > Has this scheme been discussed on a public forum somewhere?
> 
> No, sorry, I haven't found much valuable discussion about TFC padding.
> Nothing at all how to overcome the ESPv2 padding limit.

OK.
 
> I'll re-spin the patchset with get_random_bytes(). Even if the ESPv2
> padding fallback makes TFC in this case less efficient, it shouldn't
> harm. Or do you see this differently?

Indeed I don't think we should do anything for the ESPv2 case
at all without having this discussed in an appropriate forum
first.

So please remove that part completely from your submission for
now.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
