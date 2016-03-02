From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2] ethtool: check size of user memory before copying
 strings and stats
Date: Wed, 02 Mar 2016 10:48:02 +0000
Message-ID: <1456915682.3098.164.camel@decadent.org.uk>
References: <1456871112-14103-1-git-send-email-jacob.e.keller@intel.com>
	 <1456877540.3098.162.camel@decadent.org.uk>
	 <1456881113.9520.24.camel@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0lGRRIe71E+mCUKrIdCj"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Rustad, Mark D" <mark.d.rustad@intel.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"mirq-linux@rere.qmqm.pl" <mirq-linux@rere.qmqm.pl>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49973 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751181AbcCBKsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 05:48:18 -0500
In-Reply-To: <1456881113.9520.24.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0lGRRIe71E+mCUKrIdCj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-03-02 at 01:11 +0000, Keller, Jacob E wrote:
> On Wed, 2016-03-02 at 00:12 +0000, Ben Hutchings wrote:
> > NAK, ethtool is not the only consumer of the ethtool API. =C2=A0How man=
y
> > times do I have to repeat myself?
> >=20
> > Ben.
> >=20
>=20
> Ok, so essentially forcing drivers to require static sets for the
> various stats/strings/etc?

No, you can define a new and better statistics API. =C2=A0There are many
limitations of the current API that could be addressed at the same
time, e.g. lack of units, lack of hierarchy in naming, lack of
distinction between counters and other statistics.

Ben.

> :(
>=20
> Will have patches to cleanup fm10k for this then.
>=20
> Regards,
> Jake
--=20
Ben Hutchings
Tomorrow will be cancelled due to lack of interest.

--=-0lGRRIe71E+mCUKrIdCj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVtbE4ue/yOyVhhEJAQrFURAAtEmzGRi/Qm1gpH16MLT3M2qwdGkyPTRy
lPUcnU38/gtGwgmYG5yvRG7QWmmHXAbMY9Dx95dMHg1rndc0mQOTAD0BJHG2tjzN
EiKusfVG5UOwHEeWt15uSZ1U9+XQEM0OY90oHgbw9XOWdaXv9z/1I5KGpmB7OMCm
GuDSN5Ypu4oeSQf6LBm05OsnbDRe0JVUeCwe6gqX6uwzaKOBMiuqWzzocuB+szem
EesXMxZ6D4L9LLrNeF3W0Q6GZtjJwj9Ijkug8pDQf1SjJQIhbNWsBpwdquvireSP
28az+Y84gez4wJDinjY19mNmxhjK4+QcEphQWAp+yRKzNAwXrQnm1yND+iz/8NdR
s9ODVl6gtnYqT9riXa1gspITXNLFAmLwGiAr09qAKjfSMSL+PQZ/dEROqmLFEqYC
mO3fnQKlgetRS+rxadJbVss0X5y8HXGA0UJ+/DNRciB4yOf1ixJeFdhwNZEqSUxJ
55cGvye0UYI57Xn9WBbanxFFF16THanyDzTUM/T99UhoCEyHkI64kqKnB4D0ufpP
DUvELpJBQCn0h44DcMbimXPBZpxnGLfID9LnlcVJ6/YaBf5w5rYAeEKOUqRsYNWr
urrF2aKxg51IcXgMxq86X7aeF7tluoD2FTo5g1xV6ULYuP1ixNYyxYsXNdrvYa6P
98EI15SLcjI=
=EzTo
-----END PGP SIGNATURE-----

--=-0lGRRIe71E+mCUKrIdCj--
