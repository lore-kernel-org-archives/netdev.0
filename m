From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 6/8] ixgbe: add syfs interface for to export read
 only driver information
Date: Wed, 02 May 2012 01:41:47 -0700
Message-ID: <1335948107.2656.33.camel@jtkirshe-mobl>
References: <1335862269-28914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1335862269-28914-7-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120501.100241.1409452912879198250.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-yrXZqWoITxuyi/SIlmgJ"
Cc: donald.c.skidmore@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9482 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754329Ab2EBIls (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 04:41:48 -0400
In-Reply-To: <20120501.100241.1409452912879198250.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yrXZqWoITxuyi/SIlmgJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-05-01 at 10:02 -0400, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Tue,  1 May 2012 01:51:07 -0700
>=20
> > From: Don Skidmore <donald.c.skidmore@intel.com>
> >=20
> > This patch exports non-thermal (which was done via hwmon in an earlier
> > patch) data to sysfs which isn't readily available elsewhere.  All of t=
he
> > fields are read only as this interface is to only export driver data.
> >=20
> > Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> > Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> I don't like it.
>=20
> Some of this stuff is generic and belongs somewhere like ethtool, for
> example the descriptor sizes and queue sizes.
>=20
> The others are reading registers, and we have an ethtool API for that
> already.
>=20
> But putting anything like this in sysfs is pointless, because the
> stuff that other cards have too will then go into differently named
> sysfs files which, as is oft repeated here, is a terrible user
> experience.
>=20
> If you want to do this right, add a new ethtool interface that allows
> the publication of card specific unchanging values, in a style like
> what we already do for statistics.  Have one query that gets the
> string list, and then another which fetches the actual values.
>=20
> I hate sysfs, don't send me any more patches that add sysfs files for
> networking devices. :-)

Ok.

So the other two patches (patch 4 & 5 in the series) should be fine
since they integrate hwmon interface like how Ben Hutchings has done
with other drivers and do not add any sysfs, correct?

--=-yrXZqWoITxuyi/SIlmgJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPoPNLAAoJEOVv75VaS+3OsLAP/iPoWdHbXJFm6k+F2GKRlTvp
w9w6ZZDoXvS73x3QBA+FHOy1+mgqc26Pu4uGB70AgD/W9B3QcoiORLC/aVsmt1Z+
6gDjgs8FVohIas0c/13Rh9gSommVP2Mh7F1dVyx9XNYFDw/BvuoGq40HjJKlzvT4
NewuzMuZYyjG0Suon5Q6xEZ+Bmd56dTvgYZUdscJ7E02GR7DSx2qorPI3TWcqhi+
v5hYTO8Uc9fsGk4jOWaf9pFHx7flbPDrljj9urdZUCHEupRh2K28zM68YSMZ6UPG
dBZyk1YPwiRgPPrihDjQgCpqhWDDRnRGMuHaxLuVKyN+tic/sx6grPnm1CH0a2zS
4xs6C1qihckQ9LomKGkq248oU858SyaPZ1TqIbdnW2cs+e7FFqur+SOlvWY/SHQB
tR7s97Kg0e3Bp9ed1WTGpQbSZtvf9oDX9bbZ7tboPyXaCnosXgLaWGhQoE63yn5n
tCQu0NrsAij3l5SZNM7gp/lKg2Vw6eJZhulMRnJ6KrqzK4dZQmygH4qf7HgwiuTG
edDIeQ2ddHV/D1iXbZLgBk2KqWRrE1PgcJJtAIplT6zWZVWZoTD+YRtQuM683NZt
gWTYQX//p00S9heuBRlyuszgKLISI1S8+fkX/2iOQTMIjI/xUlp5gL76VhROWC4k
cLNqghS7Qn3SAYcmU5qQ
=of+I
-----END PGP SIGNATURE-----

--=-yrXZqWoITxuyi/SIlmgJ--
