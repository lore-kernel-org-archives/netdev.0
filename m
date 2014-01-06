From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Mon, 6 Jan 2014 15:54:13 +1100
Message-ID: <20140106155413.914ed0922423400deaf87926@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__6_Jan_2014_15_54_13_+1100_t/eSSbbBpBEs5k0T"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Li RongQing <roy.qing.li@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__6_Jan_2014_15_54_13_+1100_t/eSSbbBpBEs5k0T
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

In file included from net/core/dev.c:134:0:
include/linux/if_macvlan.h: In function 'macvlan_count_rx':
include/linux/if_macvlan.h:68:3: error: invalid use of undefined type 'stru=
ct vlan_pcpu_stats'
   pcpu_stats =3D this_cpu_ptr(vlan->pcpu_stats);
   ^

And lots more.

Caused by commit cdf3e274cf1b ("macvlan: unify macvlan_pcpu_stats and
vlan_pcpu_stats");

I have reverted that commit for today.
---=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__6_Jan_2014_15_54_13_+1100_t/eSSbbBpBEs5k0T
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSyjb1AAoJEMDTa8Ir7ZwVzrcP/3cBNc2ZTM6hOd6cSwkt6znO
C0w3tdLTQpFOJDDWZ87lGRga44M6V454b9u64fh/GE9En2rdWT4JjMYld6QVhS9Z
fb7MxQEwMZi9s5cgdA8ERk1+WoS14ikNwWivETMdZ7MR1lfF7jJaeHDDep9LuQ11
tn+iaDt2VBWFi3jjPwjtaesxkrazTmcyJD2YwdVxOS+RJKTw3grSppxOWeFYNgBh
djKOvbFlqF5JdisTmJ1hZRLbh5UNTkVAijo+Go6m1FN26vRXNiuxUD/IPqBI0gpO
CqP5zZ5av1HX5pS5S6AVL4bXEZcQtPiZvwx16ni7e4SoVXVTv4mHWB+ToROhJAXm
nTj1NdBcULOmKbqiPB5SDqTFeirt9S64PPTlysvvDbr9RxgD0zs9im9cXdslT4cM
ujae5V/YrwKFSEJVblXsf3PyBCw2i2JdEVzOypmNrDecBgdFlyKDa8Npg1yNsyTd
5Z7v1X6icDL9zAjJ86nFq0CTLeJ9hwaId0JvfJ1zLCqdiLw5PelulZ0JARVM+pAU
Pj+o/5QGU9/MBA5Os5aqM8ABhIQ2DsHU3/zvzbOVHYsxd43mFSgYTcFwIZGwlAJJ
dEqFZeSHXL6r3V6om5u1lu1ySJke1vt4P25rOpa68QgsoAhgu7Qxg9b4Eogi5fXI
yAXNaysMSjB4jj2B5OqZ
=EP/6
-----END PGP SIGNATURE-----

--Signature=_Mon__6_Jan_2014_15_54_13_+1100_t/eSSbbBpBEs5k0T--
