From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm tree with the net-next tree
Date: Wed, 23 Nov 2011 14:27:42 +1100
Message-ID: <20111123142742.9b4fb79fd3748325753a896a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__23_Nov_2011_14_27_42_+1100_cMGT=Q/OnerWj4Hw"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__23_Nov_2011_14_27_42_+1100_cMGT=Q/OnerWj4Hw
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

Today's linux-next merge of the akpm got a conflict in
include/linux/cgroup_subsys.h between commit 5bc1421e34ec ("net: add
network priority cgroup infrastructure (v4)") from the net-next tree and
commit 22a20a26f21c ("cgroups: add a task counter subsystem") from the
akpm tree.

Just overlapping additions.  I fixed it up (see below) and can carry the
fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/linux/cgroup_subsys.h
index 0bd390c,5425822..0000000
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@@ -67,8 -67,8 +67,14 @@@ SUBSYS(perf
 =20
  /* */
 =20
 +#ifdef CONFIG_NETPRIO_CGROUP
 +SUBSYS(net_prio)
 +#endif
 +
 +/* */
++
+ #ifdef CONFIG_CGROUP_TASK_COUNTER
+ SUBSYS(tasks)
+ #endif
+=20
+ /* */

--Signature=_Wed__23_Nov_2011_14_27_42_+1100_cMGT=Q/OnerWj4Hw
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOzGguAAoJEECxmPOUX5FE1rEQAJTVVX35i0vcp2ba53PuE5K8
6udjOmvxpbUARONSKzBt4KT1y/XXdF0kU3qUBQEDyAPJKXaf0yJr1X+kyu4Z9LKG
XQoll455vi73vaH3ywY1szfoLwHr58JejIwm3hmPXyC+XKgU3OHsEJAnTPZ/WixL
W5OdppmqA6h2n/8K2ul3IrZosz09jf22ozwdMoPPRDDixPFEti9L/FPd+/lRWhBc
ai9T/mpTJFlOm0xpk8YE2FcBcW6E/8sBCApbWUGUCCqH4SpZg0nsTwsY/FZtTOfX
L//RgGFLP95qQwYHx2Yws+sKjqwjX1ImnMNzr/Fwxa2idImswxJ9PP7hFRvbVSfm
TKdASpGkcywR4/c8JY01fPHJ6z9JeYPBFDVpt564PQinX1tCSrfIIWVeuw5s0YNc
hbZdFdhccD5BQ7646xsTCjlv3Wzgqwb0IDQvTUhq0au/hP4dYt3Sxq/sanHrhlPk
hLD2qz0bxPmnzH2KtNFZEz3hjVNcg78UJV3lJ8zifUKhpCpOkKHsXKYbfl4FwLJf
GAwmlSkyfB/9QNQoL92whgG5XqigsHZSbLxNAPMVvs1rOMmDsuucynCjRnDO/zgz
YpMh5wQZSWzUMmsVw7njfQ2Ngr1krK6RAp+q/oot6vXn1u7auaEHUsHMRBvMw3Km
GtgqhGaYSok+hzy25C6g
=cYn7
-----END PGP SIGNATURE-----

--Signature=_Wed__23_Nov_2011_14_27_42_+1100_cMGT=Q/OnerWj4Hw--
