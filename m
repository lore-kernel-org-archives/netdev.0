From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Thu, 22 Jan 2009 21:10:05 +1100
Message-ID: <20090122101005.GA15459@gondor.apana.org.au>
References: <20090122063206.GA11818@gondor.apana.org.au> <497814A7.3060302@iki.fi> <20090122064719.GA12043@gondor.apana.org.au> <4978180A.6080304@iki.fi> <20090122073946.GB12395@gondor.apana.org.au> <49782EE4.2070809@iki.fi> <20090122085053.GA12806@gondor.apana.org.au> <49783B59.90208@iki.fi> <20090122094150.GB14491@gondor.apana.org.au> <497843B6.8090407@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50761 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754659AbZAVKKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 05:10:12 -0500
Content-Disposition: inline
In-Reply-To: <497843B6.8090407@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2009 at 12:00:22PM +0200, Timo Ter=E4s wrote:
>
> Still, connecting it with variable amount length of data
> (like cert subject) might be cumbersome (extending the
> APIs, structs, especially neighbor cache).

Well you can have a translation table in user-space that turns
the cert into something more digestable, like a u32 or even an
IP address.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
