From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the final tree
Date: Wed, 29 May 2013 15:29:15 +1000
Message-ID: <20130529152915.efba860c7e825fe786b1ee99@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__29_May_2013_15_29_15_+1000_b=x_FMU/gJ=Q=ovg"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Simon Horman <horms@verge.net.au>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__29_May_2013_15_29_15_+1000_b=x_FMU/gJ=Q=ovg
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
ppc44x_defconfig, i386 defconfig, sparc32 defconfig) produced these
warning:

In file included from /scratch/sfr/next/include/net/tcp.h:44:0,
                 from /scratch/sfr/next/net/core/sock.c:139:
/scratch/sfr/next/include/net/inet_ecn.h: In function 'INET_ECN_set_ce':
/scratch/sfr/next/include/net/inet_ecn.h:137:50: warning: comparison betwee=
n pointer and integer [enabled by default]
/scratch/sfr/next/include/net/inet_ecn.h:142:52: warning: comparison betwee=
n pointer and integer [enabled by default]

I got lots of these :-(

Introduced by commit 1a37e412a022 ("net: Use 16bits for *_headers fields
of struct skbuff") from the net-next tree.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__29_May_2013_15_29_15_+1000_b=x_FMU/gJ=Q=ovg
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRpZIvAAoJEECxmPOUX5FE/rYP/3x6OkJJbYePE/Hp0wFyQwDE
zz6F2mQpukPaRLHx0mBZAMQe4ey7iMxQPAkP5g3/LsATJAoi6+fOrP/uvhUzV1hZ
iNqTQAVrVDctOCXX26d7cOLomNwLo4tJkxypsHYPEdqzEwY/hkr87n/cikbI+W5s
Y1vOVRhn5CX9K7vnRAZHfxLX0PnPUuh3a0boEh/iVjTdLP5Zcv76qaXxesJaD1U+
LUwlSpJcYK3VguVSg9swPAPlDLhPfFMetSIxBU4/JjqoLVPHfq8SGg51CPoQGEHt
x7bM+Z00+4FHYwQBArdKklfZykHYLrlXzmdtsdWlMJOEOABm5HorAVH2z1S9niYr
w8eSQwWtTPV0e28JY4zzinwSjBsjIiTmdTfAXjWo/A0gkoNSHyibTzP0DBTgwQBI
fnyDKsLiEFIvS809+3UKJdKE1Lndd1ghWtoAh1J3PwKbz1v4+l1HzwuZEyqN58mJ
stCOELhwBZ01MKPhUeV8mBMFupCWOE+kDBu+ICx833X1Ub8G2+d3hgNtk++LLrK1
Em2X64f3tR6ExY1DjTt0wrOasusexB6Z0MM5HANvcTL9bDFDL7UjrbSqQvJIgOrw
kn7nJD1pEBaRni+d61Y7Ph6S0Bdn2lGccYW4ghr9+0QcdkBlPwkxDja20NrKdhiZ
Y8mMo34idv7Q8IZgTM7V
=tNiV
-----END PGP SIGNATURE-----

--Signature=_Wed__29_May_2013_15_29_15_+1000_b=x_FMU/gJ=Q=ovg--
