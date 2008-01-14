From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Netperf TCP_RR(loopback) 10% regression in 2.6.24-rc6,	comparing with 2.6.22
Date: Mon, 14 Jan 2008 21:53:07 +1100
Message-ID: <20080114105307.GA22866@gondor.apana.org.au>
References: <1199871330.3298.132.camel@ymzhang> <1200043854.3265.24.camel@ymzhang> <Pine.LNX.4.64.0801141036400.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1449 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751958AbYANKxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 05:53:22 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801141036400.31652@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 14, 2008 at 08:44:40AM +0000, Ilpo J=E4rvinen wrote:
>
> > > I tried to use bisect to locate the bad patch between 2.6.22 and =
2.6.23-rc1,
> > > but the bisected kernel wasn't stable and went crazy.
>=20
> TCP work between that is very much non-existing.

Make sure you haven't switched between SLAB/SLUB while testing this.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
