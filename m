From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 09/18] i40e/i40evf: Add capability to gather VEB per
 TC stats
Date: Mon, 02 Mar 2015 17:34:12 -0800
Message-ID: <1425346452.2556.1.camel@jtkirshe-mobl>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1425122989-354-10-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20150228.233043.1806944010152525182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-YqUSDBPngN31mSuoRyKd"
Cc: neerav.parikh@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:31804 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752896AbbCCBeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 20:34:13 -0500
In-Reply-To: <20150228.233043.1806944010152525182.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YqUSDBPngN31mSuoRyKd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2015-02-28 at 23:30 -0500, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sat, 28 Feb 2015 03:29:40 -0800
>=20
> > From: Neerav Parikh <neerav.parikh@intel.com>
> >=20
> > This patch adds capability to update per VEB per TC statistics and dump
> > it via debugfs. It also adds a structure to hold VEB per TC statistics.
> > The fields can be filled by reading the GLVEBTC_* counters.
> >=20
> > Change-ID: I45cca003d8b12d96951a67f50d5dd7a789e09218
> > Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> For the umpteenth time, stop dumping statistics into debugfs.
>=20
> Export them like any other statistic, via ethtool.
>=20
> This applies to the existing debugfs you're building on top
> of in this change as well, I very much regret not catching
> that when it initially went in.
>=20
> Please stop, in general, using debugfs as a dumping ground
> for thing you can't initially figure out how to export via
> normal standard interfaces.

Sorry that slipped by me as well, my fault for not catching it and
pushing back on the developer for putting this into ethtool stats.

--=-YqUSDBPngN31mSuoRyKd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU9Q+UAAoJEOVv75VaS+3O0bAP/AqhzO3XXmovNGc0CYukE43d
a2N/+nCmUeCAG/kTBG5R04Rz1zMESX9wkhEh7EkWV8vh4sAIw1FoV9pF1wKkUKQl
EjJ1iBI5ZxTO58SpVtk1Os7O5PVsSdXkDTejswridBcHLs9wHcibHvTopbF27Ler
o47sKC1HHHtisqfqm6j/iwkwoP2ZWI9Hla92KwsQsFbgSQpov++kXQkrjFKM/OXT
F9F6bm6SoyOYX1dqaKfqCks5DBOhRulx64hcaRk3JHSWQTdIfJzi7qH/gQGPigAb
oZuxLmhpF5bsf6pYNslJVvzYOk0Azyxeu6qGksAYLNqbjPxyG66D0DKo3FayCKJR
lGKEPFye0ViR0ShkKxHjYGdPjubX25rnRlnoLkvS/zKBr31NGVRiEOKvY7oiWG+3
ii4pa6Ow1zepf8vblpLJZhLNBYoRfy5R0+3G0eWBWd66PBUVviFlDawtFblASFrD
wgpB0EjLaDvtlhV/B4VPJaBDCAhanYiAtgduDxVQ4d+xJ4R/D36VH1QQcQBIp6Lz
EQzMLSWzluCf8jZQIPuMuTrfQL8lv3eFjekUKwQR8djLojzHZ+s7E5YNUM+JVYeG
mvHIQ1vOTQEMeqPpZuRHThV+2co9/vSlc8O2yS/BXRi89PuYgzP5Zwy+SlIjsCom
wn5xu4cuk2vPjjrPf1h5
=1wLz
-----END PGP SIGNATURE-----

--=-YqUSDBPngN31mSuoRyKd--
