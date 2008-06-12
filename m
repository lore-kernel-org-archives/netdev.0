From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] Do not activate promiscuous mode on wlan interfaces for
	bridging.
Date: Thu, 12 Jun 2008 21:01:24 +0200
Message-ID: <1213297284.3730.37.camel@johannes.berg>
References: <1213232760.6645.24.camel@localhost>
	 (sfid-20080612_030607_332834_1EFDE126)  <1213255570.3871.8.camel@johannes.berg>
	 <1213294793.6615.16.camel@localhost>
	 (sfid-20080612_202000_504292_98E93460)  <1213294852.3730.31.camel@johannes.berg>
	 <1213295643.6615.20.camel@localhost>
	 (sfid-20080612_203408_119945_EA437275)  <1213296250.3730.33.camel@johannes.berg>
	 <1213296815.6615.24.camel@localhost>
	 (sfid-20080612_205338_785787_5D25D535)  <1213297144.3730.35.camel@johannes.berg>
	 (sfid-20080612_210012_582330_752DF319)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-PZ5tEEvCAOr5Or1J9bNu"
Cc: linux-wireless@vger.kernel.org, shemminger@linux-foundation.org,
	j@w1.fi, bridge@linux-foundation.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Luis Carlos Cobo <luisca@cozybit.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:57161 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753704AbYFLTC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 15:02:29 -0400
In-Reply-To: <1213297144.3730.35.camel@johannes.berg> (sfid-20080612_210012_582330_752DF319)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PZ5tEEvCAOr5Or1J9bNu
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-06-12 at 20:59 +0200, Johannes Berg wrote:
> On Thu, 2008-06-12 at 11:53 -0700, Luis Carlos Cobo wrote:
> > On Thu, 2008-06-12 at 20:44 +0200, Johannes Berg wrote:
> > > But in response to what mac80211 command are you sending the promisc
> > > mode to the hw?
> >=20
> > In the function associated to .configure_filter (struct ieee80211_ops)
> > in the driver, when (*new_flags & (FIF_PROMISC_IN_BSS))
>=20
> But it is a "real promisc" mode not restricted to the BSS? Maybe the
> solution is to just not promote promisc-in-bss to real-promisc when AP
> mode is active.

In fact, if it stops the firmware from ACKing packets you want to never
enable it if you have any interfaces at all.

johannes

--=-PZ5tEEvCAOr5Or1J9bNu
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIUXKAAAoJEKVg1VMiehFYUsMP/0EWezsJofDRGIOM8D5KyAci
Nca1KZv/tCe7rSU5U5u/rjPSyjYLikJYPmuD3Y00fM2UqVB5MgK9tROkZi//tsAI
fbebp6eT2zHDu1FLGslvs7oFUPfl7gqkvEelcd+9k1neqI7FEW33yIPHrLSSipGI
GSHGaldEDlAAsBCRiHzhjp6+bRnMy16IyaPZA849s3Ky8wOc5U5V/VaN+y2gI5NT
75AZJ02NvMtDcyYX4swRw4Zu/freklNxC1h+Kmy0Tgi0hVDtiTX0kjYvoqI+B4cB
oD2zEtkL5uO5StENQRwvFIXm4OmjhmDveY/FPqOjZB8mwcjOC2FEsrDmwgRpPILe
gBwi7KSBr17X1vf84SQvfOobhVcM5lBUA5PomCYzCH+efmWCKBMhXX9WbADWKufB
8ugHaisOG+SIkuFLFfVXuzuC4XSisHkdn8qx7ky4JgEhbJv6v65q14gQhCD3REcg
Rhly2lbOyzpfWou1QKDFIOAEV+1L4sThvg6Jpwmy7UlIOAtx8+sxwrp8fUZYchmx
1ziwdY9Vr9PYtpDNGq18w/aFbGZ7kk1F7mtMLbbbx217uceRe6CCIP10KQljCLXp
hH5SDjtio62FfXJ9/tZeDAtGcHKDsiM2G+AflhOoi0PEQvVIh9hS4yjPn0gOib5w
cmtpIarZQNX23o4UcwSK
=0Wym
-----END PGP SIGNATURE-----

--=-PZ5tEEvCAOr5Or1J9bNu--

