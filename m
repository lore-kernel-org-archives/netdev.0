From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 3/4] ethtool: Support for configurable RSS hash
 key.
Date: Thu, 23 Jan 2014 05:39:00 +0000
Message-ID: <1390455540.3651.136.camel@deadeye.wl.decadent.org.uk>
References: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8E5@CMEXMB1.ad.emulex.com>
	 <1390156048.16433.114.camel@deadeye.wl.decadent.org.uk>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C84C327@CMEXMB1.ad.emulex.com>
	 <1390224028.3651.72.camel@deadeye.wl.decadent.org.uk>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C84CFAE@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-eHg7nRwt1/MB8TmZ3S0z"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42799 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750831AbaAWFjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 00:39:16 -0500
In-Reply-To: <BF3270C86E8B1349A26C34E4EC1C44CB2C84CFAE@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-eHg7nRwt1/MB8TmZ3S0z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-01-22 at 12:12 +0000, Venkata Duvvuru wrote:
[...]
> > No, what I mean is:
> >=20
> > 1. An RX flow steering filter can specify use of RSS, in which case the=
 value
> > looked up in the indirection is added to the queue number specified in =
the
> > filter.  This is not yet controllable through RX NFC though there is ro=
om for
> > extension there.
> >=20
> > 2. Multi-function controllers need multiple RSS contexts (key + indirec=
tion
> > table) to support independent use of RSS on each function.
> > But it may also be possible to allocate multiple contexts to a single f=
unction.
> > This could be useful in conjunction with 1.  But there would need to be=
 a way
> > to allocate and configure extra contexts first.
> The proposed changes will be incremental so I think this can be done
> in a separate patch. Thoughts?

The ethtool ABI (to userland) has to remain backward-compatible, and it
is preferable if we don't add lots of different structures for this.

So please define the new command structure to include both the key and
indirection table, and some reserved space (documented as 'userland must
set to 0') for future extensions.

Ben.

--=20
Ben Hutchings
compatible: Gracefully accepts erroneous data from any source

--=-eHg7nRwt1/MB8TmZ3S0z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUuCq9Oe/yOyVhhEJAQrzcBAAg2sk9wFwLd8N7CeqWrk86ddxkCyuDy44
2KsgCiwqATTaYs3kIBGr+Q926Q+9HigqelXBc2L8x4YmGPtsf4RNRJSaYbvsZ7ha
U+yamVrlMZMlQpkOA4j+uAs1uecIBbi1r67GRhenyNGxAb4BsGH9XBBRVAeVoTKm
9FS3hbfikCCdj+9iVbRz0QITcgWK1wz+v2Jn2LRrzr8AKwYiOzO++vIeshJLuhOK
zx3OX9yRCF9fsAHp1Xd8Vk1H2X16Ir5O10hnvxYYYxWyTqiOvzkllixSqVD9Qiom
Mb0vsf6GxqsHawD9WF3DxTqGqHX3mdyCM7c+JD/eOMHQbWZi9E82keFKYrAKh5vG
XPXFvN3vdMgdN4GfEPY7qDuJ0iaG2TC6YyPIRdXPahnNsrBmE1Dq4hgTpyuC8lof
ZaXWkSaEleG8GtEyhpbu8aeD7SjR9OQmL4+QDn7kUq66PyA8O44cIuWVIDkyVTkz
PPWFLNNh7ENAebbMDf3m8y7GPzBvqWKSiI10yCdtSmFKtrGyS0H1UPRmoimqUcIE
5wGxxkx90kPWJtxOgeZQOYlZUGvPZXgeDibsuzcoZWOn4E4iPJ/zvKRQX4rRHnRg
rZrD1x6gTKc+RVPpLlLvSVCyQOBoUTtYo5tc52iEx85w6oaKzevu2HKFI8G9wwdk
w4rRs/5TaKY=
=nO5j
-----END PGP SIGNATURE-----

--=-eHg7nRwt1/MB8TmZ3S0z--
