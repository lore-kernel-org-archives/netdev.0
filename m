From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v3 5/9] Altera TSE: Add Miscellaneous Files for
 Altera Ethernet Driver
Date: Wed, 12 Mar 2014 21:14:16 +0000
Message-ID: <1394658856.20857.7.camel@deadeye.wl.decadent.org.uk>
References: <1394577791-6547-1-git-send-email-vbridgers2013@gmail.com>
	 <1394577791-6547-6-git-send-email-vbridgers2013@gmail.com>
	 <1394578747.28839.4.camel@joe-AO722>
	 <CAOwfj2Ot+ssTZgMoOoShVEUi+RkxjpPpRUfHAkP9RETm3TuUzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-XyGvleDHIb6KBgCdgyE9"
Cc: Joe Perches <joe@perches.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34431 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751296AbaCLVO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 17:14:27 -0400
In-Reply-To: <CAOwfj2Ot+ssTZgMoOoShVEUi+RkxjpPpRUfHAkP9RETm3TuUzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XyGvleDHIb6KBgCdgyE9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-03-11 at 19:28 -0500, Vince Bridgers wrote:
> Hi Joe,
>=20
> On Tue, Mar 11, 2014 at 5:59 PM, Joe Perches <joe@perches.com> wrote:
> > On Tue, 2014-03-11 at 17:43 -0500, Vince Bridgers wrote:
> >> This patch adds miscellaneous files for the Altera Ethernet Driver,
> >> including ethtool support.
> >
> > trivial notes:
> >
> >> diff --git a/drivers/net/ethernet/altera/altera_tse_ethtool.c b/driver=
s/net/ethernet/altera/altera_tse_ethtool.c
> > []
> >> +static char const stat_gstrings[][ETH_GSTRING_LEN] =3D {
> >
> > static const char
> >
> >> +     "aFramesTransmittedOK",
> >
> > Why the prefix with a?
>=20
> These names follow the names of the statistics found in the databook
> for the Altera Triple Speed Ethernet (TSE) soft IP. I'm not
> emotionally attached to these names, so will review the statistics
> names and follow common usage instead. Thank you for noticing and
> commenting.
[...]

These look like the statistic names specified in IEEE 802.3.  I would
support a general move to using standard names for MAC stats in Ethernet
drivers, because they are quite clearly defined and widely implemented
in hardware.  However, that is not the current practice in most Linux
drivers.

Ben.

--=20
Ben Hutchings
Any sufficiently advanced bug is indistinguishable from a feature.

--=-XyGvleDHIb6KBgCdgyE9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUyDOKOe/yOyVhhEJAQocfw/+OZj5g9dOCxwbCAext2yL7oBxxiS1t4er
hyq2whLZqe5yWJAp8CNddN2lZ7i3LwJUFI1yHzjHKZclbF1KRjWgzxJoVROvrzYp
2rwEs+x8MiBrRgDcg9jdvfI8I6hXcjfj+XWGPvpEXNppI2rYbx20qVS5M0TuRGe4
y3m6ZvfCJMBN3FqrJBU9H2/Q6uKA8QWHQRdqUXLcx++4QpRE+bI3a3SouellY7YU
3RFbIy1B71udRTX3szlTr1M/RlUz8fuNfPSGZ4lsuJtjulD33zv4owch3ls9yHQx
Tlj/7viDi6dvPKhuE7/jjHUVdKivHOMBEx9apPeCODY4xuxF2zPNVSKCWrRRhLy5
gdL9LTg3FF10iXJ0ZWWD28EG22JGCQpJdXSnzxkF3+JNhIWzIJCT8biFoFrx0C0X
snUFfQ4tDNLour7FRcc7O7rGNeFMZPLN7puvqrlF6so6S4Kj7+XegnC46T5ifjXH
JB83Nx7xfvoazDVSr4EFJyvPhswZJYtNjst+P5ElxmIPC4+N3y8ji7uPHv9Pxeb1
eyEMNmx7JQYAjxF0djwb0mGf8v/z8Xhjo6X+wsmfSAtkZhpC+x2sWIZYZJrvh+ZQ
cn5LtTavnpfdUncsUmGAQWu0N9i5S5Tgtgo8T0l1gwVterlrX6auwDext+xNeduC
bIy//Fyl6zE=
=mNrD
-----END PGP SIGNATURE-----

--=-XyGvleDHIb6KBgCdgyE9--
