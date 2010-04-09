From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Crashes in xfrm_lookup
Date: Fri, 9 Apr 2010 16:09:07 +0800
Message-ID: <20100409080907.GA2029@gondor.apana.org.au>
References: <4BBDBCF9.5060906@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: broonie@opensource.wolfsonmicro.com, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:46391 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756432Ab0DIIJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 04:09:18 -0400
Content-Disposition: inline
In-Reply-To: <4BBDBCF9.5060906@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s <timo.teras@iki.fi> wrote:
>
> Happens because CONFIG_XFRM_SUB_POLICY is not enabled, and one of
> the helper functions I used did unexpected things in that case.
>=20
> Try the following:

Ugh, can we fix this some other way?

The policy array should really only exist if SUB_POLICY is defined.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
