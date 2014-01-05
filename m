From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v5 04/17] i40e: Populate and check pci bus speed and
 width
Date: Sat, 04 Jan 2014 21:12:38 -0800
Message-ID: <1388898758.2987.1.camel@jtkirshe-mobl>
References: <1388815005-23166-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1388815005-23166-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAErSpo5fHrxTqhU+eHnB9oVwvghU=m5p=ANfkJQU0kOt9Tryww@mail.gmail.com>
	 <20140104.194942.638270130526105275.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-oR/dAou87Sw2fJjjn29M"
Cc: bhelgaas@google.com, catherine.sullivan@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	jesse.brandeburg@intel.com, jacob.e.keller@intel.com
To: David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56301 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750747AbaAEFMv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 00:12:51 -0500
In-Reply-To: <20140104.194942.638270130526105275.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-oR/dAou87Sw2fJjjn29M
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-01-04 at 19:49 -0500, David Miller wrote:
> From: Bjorn Helgaas <bhelgaas@google.com>
> Date: Sat, 4 Jan 2014 14:04:30 -0700
>=20
> > I don't see anything device-specific here.  This all looks to be
> > generic per the PCIe spec, without anything specific to the i40e.  In
> > fact, this new code looks almost identical to what Jacob added to
> > ixgbe with e027d1aec4bb, except that Jacob's code checks the whole
> > path up to the root, not just the single link leading to the device.
> >=20
> > Since you're doing basically the same thing, it'd be nice if the code
> > looked basically the same.
>=20
> Agreed.
>=20
> I'm going to pull from Jeff's tree meanwhile and ask that this consolidat=
ion
> happens as follow-up changes.
>=20
> Thanks.

Agreed, I will work with Jesse to make sure those changes get into the
driver in a follow-on patch.

--=-oR/dAou87Sw2fJjjn29M
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJSyOnGAAoJEOVv75VaS+3OWogP/22D9irOt1nx0as04+vdnSER
rFgNfr6fBpbYIchvqqef59ZelvEkGA0iNnwvEwg3TX/XBHl9NM4LEfWzAC45mlZJ
AQ6qoP6WbQjRhUSBC1o3TkYFE1hftdn2NLOBk12arqamFeKUhUZxlhbQNSeo742A
ihFLTKpgugNoPsL1LZ6x3CV2BGIgocWEknUuUZX7qT9jI5DVsjmYlS4lkUaGaWGw
AzYv5urF9SSffR8a6t09rMWJn/eRd1Z/BsjHXyoqWGBsVJVnpE7vqv3rCV6JGFth
QJSqk1iQ4RcsNamW5syF3DwcBzXAh7ZxDCSG6QYebQz+vwG6VroLNrywblW+hiQA
/x2RjwGuoZBYabrslDpY+YL2mXGZYnla0Q+ww09vio32CW4NJ2af95cy7zGPL8wn
CRSEkHeyBv/iU+pFKxiIkOdPhiWfSAtZEKKojULL7Tl/rU8f+VoQ6KWE6yPjjVtQ
tkvEya2kHd+6sBKyS2Id9KRmbh5t8+nOIJgP44c8AV8HEtNrJcnxoaS3r3Ysvqjr
LHvwIGohsdxl981GeA8CkazuPXZjtoBlyNl17AFtoi01dmk6hpwWmP2evYnKsytO
b3atY/6M4HXbo4s1ajPyDzzqjddrlMOsSJ7Gnh6DNI7y3Y9Qdrz3rZ4EbIckinSn
ZnAewSKo619w7xAQT76Q
=njvc
-----END PGP SIGNATURE-----

--=-oR/dAou87Sw2fJjjn29M--
