From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 22:11:06 +1100
Message-ID: <20080117111106.GA8932@gondor.apana.org.au>
References: <E1JFHDM-00010A-00@gondolin.me.apana.org.au> <1200533980.4451.100.camel@localhost> <20080117021743.GA5182@gondor.apana.org.au> <478EED98.6080603@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35800 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751238AbYAQLLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 06:11:13 -0500
Content-Disposition: inline
In-Reply-To: <478EED98.6080603@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 17, 2008 at 07:54:32AM +0200, Timo Ter=E4s wrote:
>
> > Racoon doesn't use pfkey dumping as far as I know.
>=20
> ipsec-tools racoon uses pfkey and only pfkey. And it's non trivial to
> make it use netlink; it relies heavily all around the code to pfkey
> structs. It also runs on BSD so we cannot rip pfkey away; adding a
> layer to work with both pfkey and netlink would be doable, but just a
> lot of work.

Sure racoon uses pfkey but the question is does it use pfkey dumping?

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
