From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: origin tree build warning
Date: Tue, 25 Aug 2009 10:11:47 +1000
Message-ID: <20090825101147.fb929fcb.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__25_Aug_2009_10_11_47_+1000_5fYDC3ARW03IRdbG"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754023AbZHYALy@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__25_Aug_2009_10_11_47_+1000_5fYDC3ARW03IRdbG
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Today's linux-next build (x86_64 allmodconfig, gcc 4.4.0) produced these
warnings:

net/sched/sch_api.c: In function 'qdisc_watchdog':
net/sched/sch_api.c:460: warning: initialization from incompatible pointer =
type
net/sched/sch_cbq.c: In function 'cbq_undelay':
net/sched/sch_cbq.c:595: warning: initialization from incompatible pointer =
type

Introduced by commit ee5f9757ea17759e1ce5503bdae2b07e48e32af9
("pkt_sched: Convert qdisc_watchdog to tasklet_hrtimer").

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__25_Aug_2009_10_11_47_+1000_5fYDC3ARW03IRdbG
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkqTLEMACgkQjjKRsyhoI8zhVQCgja2wHctWF+B3qYuGAVEIfNcA
HTQAnA7Yu6Vn6fWPBVEHhb2qSf+G+uSK
=ha/j
-----END PGP SIGNATURE-----

--Signature=_Tue__25_Aug_2009_10_11_47_+1000_5fYDC3ARW03IRdbG--
