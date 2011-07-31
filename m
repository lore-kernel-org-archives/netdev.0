From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC net-next v2 00/71] Organize/Move of the Ethernet drivers
 in drivers/net/
Date: Sun, 31 Jul 2011 12:00:40 -0700
Message-ID: <1312138840.20837.118.camel@jtkirshe-mobl>
References: <20110731154515.GA3357@p183.telecom.by>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-1GG62ugPf6mmwJ/43ZAF"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40029 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752570Ab1GaTAl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2011 15:00:41 -0400
In-Reply-To: <20110731154515.GA3357@p183.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1GG62ugPf6mmwJ/43ZAF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-07-31 at 08:45 -0700, Alexey Dobriyan wrote:
> > drivers/net/{ =3D> ethernet/3com}/3c501.c
>=20
> I for one appreciate that Linux has short overall directory
> structure. At work we have like 5-6 directories before
> actual code and it sucks very much.

I agree to some degree.  I agree that it nice to only have to go 2-3
layers deep to get to code, but it is also not useful to wade through
357 files in a directory.

drivers/net/ is the largest directory under drivers/ and is 2 times
larger than the next largest directory in drivers/.  There are 2255
files/directories in /drivers/net/ and majority are Ethernet drivers.
It has gotten to a point where there needed to be an additional level(s)
of organization.  So yes, you have to dig a bit deeper (but it is
logical).

drivers/media/ is the next largest at 23 MB with 1526 files.

>=20
> > have tab-completion actually work
>=20
> What do you mean?

What I meant was that tab-completion not becoming not useful when you
get >20 results, you usually end up having to type the entire file name
for what you want.  It is nice to type 1-2 characters (and then <tab>)
and get back <5 potential or exact results.  David actually brought this
up as an advantage to the new directory structure, which I agree with.

--=-1GG62ugPf6mmwJ/43ZAF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJONaZYAAoJECTsCADr/EWUfXoH/0+uCpXLxAQZxQlx3uteq19l
3po3oxpp/wn4K3FmmgnmHGi1lNqbuiftO5eTHcfgZ6G7A7yHFaRMjRv+ySXM8vL/
RJthEEV58RvaFAJp1ClLtDUnRs0sikQXuNSqHGkjbgqC7CaA5kGrtz3KK1cC98tV
erj8BQPQc/vdVz44ziSoiqdXrQnbkUrS/lneA8YTb0/Rqs9NKv2prZIy+BGOVQWZ
klos5UKN4bPp2u6ETYi6ht0o7ji4q2kuFdCQAyk3w7XgTiQbYD3ey1ht9C5P0pvE
bTN0DdRtHFniUAdL0bjhf6cJbBE3hkb6Mxu6T+hl1mUFwbsH8FUbBc8rEZ1rGvo=
=Puxc
-----END PGP SIGNATURE-----

--=-1GG62ugPf6mmwJ/43ZAF--

