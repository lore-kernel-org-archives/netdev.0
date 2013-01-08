From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the drop-experimental tree with the
 net-next tree
Date: Tue, 8 Jan 2013 14:15:13 +1100
Message-ID: <20130108141513.573d65ff946749624c9b4281@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__8_Jan_2013_14_15_13_+1100_lsZWrqV6hTh/1zuw"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: Kees Cook <keescook@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__8_Jan_2013_14_15_13_+1100_lsZWrqV6hTh/1zuw
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Kees,

Today's linux-next merge of the drop-experimental tree got conflicts in
drivers/net/ethernet/8390/Kconfig and drivers/net/ethernet/i825xx/Kconfig
between commits 483f777266f5 ("drivers/net: remove orphaned references to
micro channel") from the net-next tree and commits 16f5471ff2da
("drivers/net/ethernet/8390: remove depends on CONFIG_EXPERIMENTAL") and
65af6f091e6d ("drivers/net/ethernet/i825xx: remove depends on
CONFIG_EXPERIMENTAL") from the drop-experimental tree.

I fixed it up (I used the latter versions) and can carry the fix as
necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__8_Jan_2013_14_15_13_+1100_lsZWrqV6hTh/1zuw
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQ649BAAoJEECxmPOUX5FETPsP/RkelQ9UNweMhzUjSrU0tawT
I+0pZjBXh8HviV+KFnRvSPYtP4BfoqGPmRY0l2gUZCEuz0O1m6jb7O9pWXteBKbH
2HJEH5xg+o8Zxd5P143PAS39K7mvN2ui+FoUGXGABjGFambJbwi6P4Lgr+KI/Xrr
WTl8z9lcTHMrraz9q64a+O3jHgzp7u4+q/k+qe3jTVp0VCA3Tl5yBUzInFc/ig0a
B/k9g1UNZmUEXQbqjbsXrQ5Tb4F3cE0KCsCovIdsfWMp6AIuQP1iaqmv8Jbdwb30
jD16z5BOh89HQAavAOnylO6+bh2aG6k9OqbC6pz669dr3jRfW7JHKjo2Zhp6T3MW
EMAEtrq+Ym0oZhnZaWOo09pABXylIdw/vZ73wmaze+j9l/inukJBWEaqqCImJxBC
Co6rAfdOXmfVs1Fu0a/4O6crbRDQ1J9o4qRnk8WPFi451ATjIJnDYvY28+PDm1T/
IOwYBXbP5zUGp7f4zM64pGXgOu2ZxyqEqnP4c/f0BrcOYXo60w7bHN3m1Z701g5O
vC7JBmZgnRE8vXUR4JlfKo0rUrjANz560S5Iy+Y4r5pic1WZQNxkDLIUdWLp2X0/
bHcMqluhJXf1uGwD+VJgfNcJcEXAWjU8h9Oi6OzSmMZ6J31O1wLvJCxODvSfHMfH
v7OMpxCJU8vNN9Cs/mwB
=+Uaz
-----END PGP SIGNATURE-----

--Signature=_Tue__8_Jan_2013_14_15_13_+1100_lsZWrqV6hTh/1zuw--
