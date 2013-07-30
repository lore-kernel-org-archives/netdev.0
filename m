From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Tue, 30 Jul 2013 12:16:05 +1000
Message-ID: <20130730121605.35c4de9d82b753a5a763f5c9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__30_Jul_2013_12_16_05_+1000_4isAhAXf5loV4.2D"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Andi Shyti <andi@etezian.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__30_Jul_2013_12_16_05_+1000_4isAhAXf5loV4.2D
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (x86_64
allmodconfig) failed like this:

net/9p/trans_rdma.c:724:15: error: 'rdma_cancelled' undeclared here (not in=
 a function)
  .cancelled =3D rdma_cancelled,
               ^

Caused by commit 59ea52dc461e ("net: trans_rdma: remove unused function")
interacting with commit d538a4ba906a ("net/9p: link rdma_cancelled in
with trans_module") from the v9fs tree.

I just reverted that net-next tree commit for today.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__30_Jul_2013_12_16_05_+1000_4isAhAXf5loV4.2D
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJR9yHpAAoJEECxmPOUX5FE0dYP/0OAiecjYd4w+YW3GF0RXpws
vWS0zfJF1ASkdhK52ujQ11lVZfc97GfBjizJZ66PtNjL3Y/w6wtEu+Y0cJ4O/z8t
PDa+pMnOC5ZIHcsk/Y72nr93k05EFEhmLvaIcXK3ehRaiQaqbCnSHRXAMbvh6mPy
ajoFVn5X5gOlFebaEsyyBCYMCD9IxRVdcGIYxPtvbEnKQ+/xqsQeQKa+GQsD+yGr
aqFVCENmPtfIf+MloKFUVoFlRG3swaoqZUDboXjN2L1WrcptGU4pU82YgCu+E1wQ
CB76e3O41abYGHwJ+aolAdRhE2z7ZG4h+sONdktPjR5RGm309JxMLjfkp4Pjk6c+
7OBdXu4JRrfYlaWDMXGKMG4RrcVfUTE3BPec7DjKcG6ucaMizEmlzoFyxgTqogLz
yXlLMFa9QJgqgtBNmVjA/V2QSr0rAZQPMpM2XdCYzX1P8qy91/m2riRnCjvHGSPk
1JKAedG/AGxR3Yt8VRAcsWJDEhs0Hzs4ckwf92plQh9zQ+72lF34Q7eUKFLnMR/R
bYzoP2CVcSZ0Nf5HXf+Mn9V+MhIqCsnJJCXFcPvQR5+i4+LBAT6Gtpt1RGwpDDxC
VeSvwCJhK1Ee2bEHCFyu8y+S8PvH3K88oq1Ty+eY1ioU9vNTYM9VYtrh+x/iEgJV
1dVswf/TE2JUdal+Dl9C
=8wLd
-----END PGP SIGNATURE-----

--Signature=_Tue__30_Jul_2013_12_16_05_+1000_4isAhAXf5loV4.2D--
