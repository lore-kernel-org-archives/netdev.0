From: Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCHv6] net: Add batman-adv meshing protocol
Date: Wed, 1 Dec 2010 20:04:33 +0100
Message-ID: <201012012004.34356.sven.eckelmann@gmx.de>
References: <1289136377-18350-1-git-send-email-sven.eckelmann@gmx.de>
	<201012011954.20275.sven.eckelmann@gmx.de>
	<20101201.105615.48506929.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart11849087.JQigvWNdX2";
	protocol="application/pgp-signature"; micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20101201.105615.48506929.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart11849087.JQigvWNdX2
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

David Miller wrote:
> From: Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
> Date: Wed, 1 Dec 2010 19:54:19 +0100
>=20
> > Do you have any more possible duplication you have in your mind right
> > now?
>=20
> The hashing code, for the third time.

And I asked in the past about the removal of the hashing stuff without any=
=20
reaction. So, we removed most of it. resize and iterate will be dropped too=
=2E=20
So, is it a problem to have a hash_find, hash_remove, hash_add? These were=
=20
created to reduce duplicated code and not to create a complete new dynamic=
=20
datastructure (which it isn't... it is just the usual hlist stuff)

thanks,
	Sven

--nextPart11849087.JQigvWNdX2
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJM9pxBAAoJEF2HCgfBJntG7HoP/1sFnPJ2SKi0nvgnLFd16bt8
7e3fYB3aazQu8ECfrWgzTBM/IaAxFe6YgK5w6VqQzSDyEJTXV4zJO9MSRpy3jBkT
6yYG1ldgQ9CoSoCKSaL1oo5wfbA3I5ShAvnJExAz3p0MXpTrifCPWjs10vdj46qX
lMnqjkZDW7h2lnxKGBVxlQbZthqvyyIaOuIRoLyXNz8V6ePPv+EEA+CNQqAd9pua
4N4xmMD6utzUmLiZ2jbtbGkCbcX3fRIPZPxy56U9GNlpT+bJRYwpJHDpCZOfSopJ
Hnb0UualMffvnUFiYaasDpTdvTOCHdQvyd0cdxtXWfr0P3oO+0zMT88qepTaINP2
AgVYI334/tGZGWWD3j2563FwP7aQrZfNMph1VhK6bWWEFdGIGdXcltS9LAyoBX0w
xoh75WDa228A68N0kUwGvUrN6q1HWm4w+5v/XuT2vEh2o/1ELiCe6eRwHkZsrYyh
+r1Yt91StyU0lh1qI209HGh+odargfhw2007jGrWfK+wJ88gCC7/qH3L/HsKf3G9
f9rVjo2P5N2v8zVHz4zfX+o26ff6yjH8P3n+Dacnafpqd+CmSKJbAIVBRw7vmEu9
5IfT12gK4846735euIDhTzCT1hSiWFn6CMHCV9H6CM4+oZqNMfRL1qVKGOTwO3vD
Q+Q2j6/eAdbHkQWcQK6B
=f5X0
-----END PGP SIGNATURE-----

--nextPart11849087.JQigvWNdX2--
