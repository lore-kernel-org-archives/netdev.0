From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 2/2] e100: enable transmit time stamping.
Date: Wed, 04 Apr 2012 02:34:48 -0700
Message-ID: <1333532088.3046.22.camel@jtkirshe-mobl>
References: <cover.1331400160.git.richardcochran@gmail.com>
	 <33c61d135f4fd62e5128466633302414ead0092e.1331400160.git.richardcochran@gmail.com>
	 <1333530283.3046.14.camel@jtkirshe-mobl>
	 <20120404093011.GA4292@netboy.at.omicron.at>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-T/R6Bjf2/XeEkOUvtXZ3"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37224 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753594Ab2DDJfE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 05:35:04 -0400
In-Reply-To: <20120404093011.GA4292@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-T/R6Bjf2/XeEkOUvtXZ3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-04-04 at 11:30 +0200, Richard Cochran wrote:
> On Wed, Apr 04, 2012 at 02:04:43AM -0700, Jeff Kirsher wrote:
> >=20
> > I had this patch in my queue, but during testing we found some serious
> > issues with some adapters.  With every 82559 based adapter Aaron tried
> > the system would panic on driver load.  This included at least one
> > sampling of D101S and D101M.  Every other e100 chipset Aaron tried
> > (82557, 82558, 82550) appeared to work fine.
> >=20
> > So I am dropping this patch as is due to the kernel panics.
>=20
> Okay, fine. That driver is strangely written, with weird callbacks and
> passing function pointers around.
>=20
> Taking a second look, I think I might have found the problem. The
> drivers casts a firmware pointer onto a skb, and my patch then tries
> to timestamp the firmware blob.
>=20
> If I rework this, are you willing to give it another try?
>=20
> Thanks,
> Richard

Yeah, we appreciate the work your doing.  Just send me an updated patch
and I will add it to my queue.

That was our thoughts as well regarding the firmware blobs.

--=-T/R6Bjf2/XeEkOUvtXZ3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPfBW4AAoJEOVv75VaS+3O5p4P/RbDIVnPsBPZwzmc+31efS+U
+xrSSYcG5eoAvcneVvkNdN+OV7bfyH3X5oJrFX3AIsMfW/0evVEXPmVIqmqiC8Go
JXw0IorDwGFVOSA6+5meZ4Ct8FFTL7ixosvRr6Zlp5rYzwYscbM3JV83qqe7qd9A
N46N7wdd1cA8fd5+DtopdmtU4+eg8mL+EAbZt1F5/vbgk5yTSvDOmVUabMdp3MAd
yFIRkHZLfve76oJF8oxNXqbvrYm/LXeRg/W2a+ZxoBd8GBXV8LU3g/7ubwzEqdCx
I85eV3AO08pRX3R9VLdZ94Ru+6jFzVwYV3QRfx0fN/mkMNmZ1GI4lEylbc/e6mzU
LRRKy/f849M/FqyyWCEvYaYJ3n+Xo4R53WRaj7xAwvc/76e4YmAKY9RBfd3jqq3T
nNno0jCz1eCJL8L2AN2peq9M20Ps7YOkXmqiCmG0y3zshagRn2+7jcK5gO4qRMup
28S48icsmt1CAuMaRuyrvzZV1iovp2ZPDGK6JZIJHNNzpGZhKOibFk3hn/yavSOE
IrENRi7IR8aRQaEJuWHFaEXrJGI6mtt0BYsb5/ROz6y4Wtb8u40eQ66rGyQMgC0E
jS9KxVL/8JqGoTlRSL09DVxLzJj96Z43MD46uRR5NhKG8YI1HODSrKfBmX1A/WwP
tUL7Z8Td9yI6Q7GlD79m
=hF3P
-----END PGP SIGNATURE-----

--=-T/R6Bjf2/XeEkOUvtXZ3--
