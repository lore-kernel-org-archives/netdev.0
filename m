From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [3.2.y] e1000: fix vlan processing regression
Date: Sun, 28 Oct 2012 00:11:08 +0100
Message-ID: <1351379468.21585.9.camel@deadeye.wl.decadent.org.uk>
References: <1332917548-13102-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1332917548-13102-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20121024012118.GA6898@elie.Belkin>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-eLwvlAYnyb1mja5BxQWa"
Cc: David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>, sassmann@redhat.com,
	"Andrey Jr. Melnikov" <temnota@kmv.ru>, stable@vger.kernel.org
To: Jonathan Nieder <jrnieder@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60542 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750799Ab2J0XL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2012 19:11:26 -0400
In-Reply-To: <20121024012118.GA6898@elie.Belkin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-eLwvlAYnyb1mja5BxQWa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-10-23 at 18:21 -0700, Jonathan Nieder wrote:
> From: Jiri Pirko <jpirko@redhat.com>
> Date: Tue, 20 Mar 2012 18:10:01 +0000
>=20
> commit 52f5509fe8ccb607ff9b84ad618f244262336475 upstream.
>=20
> This patch fixes a regression introduced by commit "e1000: do vlan
> cleanup (799d531)".
>=20
> Apparently some e1000 chips (not mine) are sensitive about the order of
> setting vlan filter and vlan stripping/inserting functionality. So this
> patch changes the order so it's the same as before vlan cleanup.
[...]

Added to the queue, thanks.

Ben.

--=20
Ben Hutchings
Reality is just a crutch for people who can't handle science fiction.

--=-eLwvlAYnyb1mja5BxQWa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUIxqDOe/yOyVhhEJAQoYwhAAr9RLRviFrs84JKot4FG3pFH67ek1NH5Q
48RpMDhCbs3sC0eSQFLRbH98lqNYhj4GmZKshDbPN1y+Eo3WziiOyq0dSuQv4OpW
/3JulzEBHjygzZ4d1kLYHELsuFexvauRMjym2dDcoJisVNzegDs80jDJ6x6+vwty
cAtcstSnNNXUmGwD1RSIL1bCrAMXM6IFJYjQnPY3wDM7nvVi3vNIXQqbdFIO3dPA
oiO4vFeIbncSXAON5HPqHWRt8a3K9TdI9BRE5zgveGlUg2rsO72w/90bl4Fg1awp
Xhlje8tCLgrWCS2XItby8f8FbQfdfoMYKmc6+6Xt/qBeF+XoZnQUy4W7oHOdgxFm
bteEaX6JeMBSIL3N/JXJj04O2cNywz64nfOyKRFVvk0N+ZoG0mS75bgUtiunaUnY
Nnu3Dif+gPWPEjTKz5MhxGt4RSQ+yLdJniFQNj1c7cvTYzuUIQ+q/WQC85uQdhxq
pucWs7Zy2CchOpkwtKtmds/R7GOE/SndevEiyKXX/YHWPFyhIEAdr3WQPh5v3b/W
8m0NaJzC3VH7WrZvIMJ2tJLuAA2LLxXSU+NR88sXrNPncxYtTJZfqWnZ2Yd5Uvcz
O4rxc6x4TnUbRdMwbGh5Ag2zucVWWouafwlOVZL3dAonWmTVUi22+S5458zP1dRD
GXGFaINW/Uo=
=zKkd
-----END PGP SIGNATURE-----

--=-eLwvlAYnyb1mja5BxQWa--
