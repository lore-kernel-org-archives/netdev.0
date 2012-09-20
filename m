From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Regarding ethernet directory between IP and SoC chip vendor.
Date: Thu, 20 Sep 2012 01:35:57 -0700
Message-ID: <1348130157.2006.87.camel@jtkirshe-mobl>
References: <CAG4h5ywgCS0n8t70uUNmSOVhKBPkOLeVLaO+D4tYfUT2qN7qTg@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Fxm7SpPZEhQiCU3aE5vT"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	peppe.cavallaro@st.com, deepak.silki@st.com,
	francesco.virlinzi@st.com, eilong@broadcom.com,
	alexander.h.duyck@intel.com, bhutchings@solarflare.com,
	linville@tuxdriver.com, wey-ty.w.guy@intel.com, coelho@ti.com,
	e.wahlig@samsung.com, aditya.ps@samsung.com, ihlee215@gmail.com
To: byungho an <bh74an@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40680 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752082Ab2ITIgA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2012 04:36:00 -0400
In-Reply-To: <CAG4h5ywgCS0n8t70uUNmSOVhKBPkOLeVLaO+D4tYfUT2qN7qTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Fxm7SpPZEhQiCU3aE5vT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-09-19 at 21:39 +0900, byungho an wrote:
> Hi all,
>=20
> I have one suggestion for ethernet dir.
> Currently It is well-defined and good for management.
>=20
> But if IP vendor is different from SoC vender, It is a bit confusing
> to guess dir name.
> For example, stmmac is using Synopsys dwmac.
> In this case, if another SoC vendors try to use Synopsys IP, they
> sould make their own dir under the their name? Even the IP is same...
>=20
> If there is common dir of IP vendor, It would be more clear.
> If that, other SoC vendors that try to use the IP can make their own
> directory and drivers intuitionally.
>=20
> What do you think about it?
> I want to exchange opinion and find a resonable and rational way.
>=20
> Thank you.
> Andy

A lot of thought went into how to organize all the Ethernet drivers, and
after much discussion, it seemed best to organize the drivers by the
manufacturer rather than by who was supporting/writing the driver.  The
reason being is that the manufacturer of the silicon was not going to
change as frequently as the driver supporters.  We did not want to have
to change the location of a driver every time a company was bought.

I personally am open to suggestions on improving the directory structure
so if have an idea on how to improve the directory structure please
provide a patch.  Keep in mind, that drivers can not keep moving because
some company bought another company.

--=-Fxm7SpPZEhQiCU3aE5vT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQWtVtAAoJEOVv75VaS+3O0eIQAJo3OXG5QXpGKvWmAvMP3ISw
Oqb/YeW9qBCkpMyh3YtNxFWkEAHzL0biZDcxjXXfHz1h+qutnYica4+cNxGDhEWu
dtz9cuF0PyxAj7zy4XNhS3SzeOthqwlY6uogkIaZ0x+81tz2xTD9V7Bqa1jeIFGI
7y/Clkj80TS4XQtzD982OvZ2B7UM2GIy9gu7f4yd8bQBbJ3x0OL6SUKq8YjHw9TH
ZHoePV7HAz85Z2TOjx0HI4guzUA+9RYgyLN0tGNiBJQD+Mq3HSrb3RVS3uA0ODbI
3/Rgi5YK7ig/i5YhnJzqlT5wIICYzGD7yPoCD0awJ1b1pdV2pLbMdyFIKqdXFuSU
EMQHzAYDYho7eYOw09TZZUmcbZtWKa0ZrygIq1d0iPrTN6+fdHNDjmIj/xkZHNkQ
JhxTQ9VYP0jz4Q2iJ76u55kFK+ys02EqQgRYPOdclS1OIoN/gaHKlL8WonQaRuRe
nngbz/uFSiZ5Zli4YG5uyGrT3gWdX3rJgUeYyCzoPn/9dghAF3CYwC2H0vo1/w69
dvbCXALyFQj2K8L2cOKEKz7aq5fNvvB6auGLBaS3A+yY5fH+DtcGRqulDKKuDGaV
HQ5VQM7kXw7F+VJ/bzTaKRgH6tILbVduJJkrzzUn5ThND93QJ8BP9JYC2hnCOJX2
HTibghff0cDxn91jN6ft
=0jrA
-----END PGP SIGNATURE-----

--=-Fxm7SpPZEhQiCU3aE5vT--
