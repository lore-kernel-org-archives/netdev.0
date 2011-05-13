From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net tree
Date: Fri, 13 May 2011 11:41:39 +1000
Message-ID: <20110513114139.b1ed88ae.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__13_May_2011_11_41_39_+1000_KaUW_T__n8NIP7Du"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__13_May_2011_11_41_39_+1000_KaUW_T__n8NIP7Du
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (powerpc
ppc64_defconfig) produced this warning:

net/ipv4/ip_forward.c: In function 'ip_forward':
net/ipv4/ip_forward.c:87: warning: 'iph' may be used uninitialized in this =
function

Introduced by commit def57687e957 ("ipv4: Elide use of rt->rt_dst in
ip_forward()").  It may be a false positive, but it is not obvious how
iph is assigned before being used.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__13_May_2011_11_41_39_+1000_KaUW_T__n8NIP7Du
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJNzIxTAAoJEDMEi1NhKgbsFuIH/R/yVDbc5cwdROVHSfJHdXM7
3686qNrdMjOuojJlJeKKCkgi0pt/sEL30W9PlcjyfdgtE/7FWfvnddpTFZ4xrgdR
Ap1ZwNjvnv40xrqmdCdnEorZm0s/CLPuUyxwhW1hMu29wb+Bto7q7iR580bxs08+
V2wVlDNyTgqo0nG6oqJVHyqO0CAVfXMIYF/rxtsq1f955P/ZpcYND8CkGGrUkMDw
EGCYt5BVIn6ShQmv22TkRqB09UZIPo2q6f5xNrmi8uaZ5QyeqwhVDb2kGrs1PSiz
khB+0pKjUO02HOzI2wP7szRC0vkslHYLhXkCRLPjrfqUGrFtX6xLY86bTAueS3Y=
=iRcG
-----END PGP SIGNATURE-----

--Signature=_Fri__13_May_2011_11_41_39_+1000_KaUW_T__n8NIP7Du--
