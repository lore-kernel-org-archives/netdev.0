From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] Pull request: SIOCGHWTSTAMP ioctl
Date: Fri, 06 Dec 2013 23:30:58 -0800
Message-ID: <1386401458.2365.29.camel@jtkirshe-mobl>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
	 <20131205.194624.1335606571649336470.davem@davemloft.net>
	 <1386351515.1516.156.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-VbUB9WE2HdZari6us9UQ"
Cc: David Miller <davem@davemloft.net>, richardcochran@gmail.com,
	Veaceslav Falico <vfalico@redhat.com>,
	David Daney <david.daney@cavium.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org, Takahiro Shimizu <tshimizu818@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:32167 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751774Ab3LGHbY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Dec 2013 02:31:24 -0500
In-Reply-To: <1386351515.1516.156.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-VbUB9WE2HdZari6us9UQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-12-06 at 17:38 +0000, Ben Hutchings wrote:
> On Thu, 2013-12-05 at 19:46 -0500, David Miller wrote:
> > From: Ben Hutchings <bhutchings@solarflare.com>
> > Date: Thu, 5 Dec 2013 23:37:12 +0000
> >=20
> > > 1. Add the SIOCGHWTSTAMP ioctl and update the timestamping
> > > documentation.
> > > 2. Implement SIOCGHWTSTAMP in most drivers that support
> SIOCSHWTSTAMP.
> > > 3. Add a test program to exercise SIOC{G,S}HWTSTAMP.
> >=20
> > Pulled, thanks Ben.
>=20
> Thanks.  I hope all the drivers still work, as you didn't leave long
> for
> review.
>=20
> There are a few drivers I didn't touch because they don't appear to
> keep
> a soft copy of the timestamp configuration:
>=20
> drivers/net/ethernet/intel/igb/igb_main.c
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> drivers/net/ethernet/octeon/octeon_mgmt.c
> drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>=20
> phylib and the dp83640 driver will also need to be updated to support
> this.
>=20
> Ben.

Thanks Ben, I have let Carolyn Wyborny (igb/igbvf) and Don Skidmore
(ixgbe/ixgbevf) aware of your changes so that they can possible make the
changes to those drivers as well, if need be.

--=-VbUB9WE2HdZari6us9UQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSos6yAAoJEOVv75VaS+3OXyMQAIlDPg6Kg9XFDx88hfdUIuMS
/xckijayZgWzHBMfjb0dAP6P52H38HQFjTMqc2++5Wa3rsUswptGbZGq8af9D+Al
ShvvM8Lwy81orxZpNuhJ4EHWeLTymWLJLcv5NvahV7wdWcodAHuezKC3++rhgdbg
YI48YKAVr1VckchuIFERRY7NHxahQOuGRWQl/XOt2lshLPBWBXE8CNfDuTZCndIx
XeOxHZZGw1ZTgH11rn1zkKL4ZdKrco8iYKYmT/SmJ1YbPp5kWaxEXmsNwjZGrLlU
NAwJb7MOSK1QAZbuJ0f7uaA8cvRoTQWzA5Q9tb5TNdRrbS9he+VmSaOLWASiCHc3
JmDBjhC1T5hc1rOMnElnXE/yEJoL9o1Nxt3mOc5UHZDMl6CoTX6WPWICqt8xZI/T
FUiLZW04eG6MsJ4H8Pi8toxdb7IEhxNcT79qfINnd1lJzFE0+DEtM7epIUeb4XRy
Di2WHI3MbXRsJExh+G9SVH5US3zJ2ypLvTERGfy2ltqAcxRJdKPEwU8fUwDbXRux
76zOoslTc2cdLz9ZL9vyO5KNTeiCONplATAXzqTfSpOJo7QfSRMh0QkUqcRPfEkM
Wr7C/jVzn2tfp4rnWkyR2jzPoio1QUYFcvxW/hPBoIeVgYOSltDWk96p4zz9qc+3
Zh5cPCM6ZN4rsfzUHtiA
=r3nO
-----END PGP SIGNATURE-----

--=-VbUB9WE2HdZari6us9UQ--
