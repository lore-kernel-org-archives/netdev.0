From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net tree
 related)
Date: Mon, 18 Oct 2010 18:36:16 +1100
Message-ID: <20101018183616.ef5cde84.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__18_Oct_2010_18_36_16_+1100_X0fpucxB3q/_ulKV"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	stephen hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__18_Oct_2010_18_36_16_+1100_X0fpucxB3q/_ulKV
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

net/tipc/core.c:249: error: __ksymtab_tipc_get_mode causes a section type c=
onflict

Caused by commit 31e3c3f6f1f9b154981a0e6620df700463db30ee ("tipc: cleanup
function namespace") which made the EXPORTed function tipc_get_mode() stati=
c.

I have reverted that commit for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__18_Oct_2010_18_36_16_+1100_X0fpucxB3q/_ulKV
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMu/jwAAoJEDMEi1NhKgbsruEIAISF8UKqLQ7kEioTa0v4n6gE
sXR+4ML7Uq/ERw8lPs++VQrTYAZq4d9F/AdDzFeuuetVWUAolHLSVzONEZzW1s7c
N6Iew6i8+PAy3aG/Jqd18HB7U46/mEjit6jGock4j1SRPTNEv3umXpKtVvztw8Bx
NmB4jTLQ/pXlD5z1Dwid0C68wo5C2TiqzwhDis5fBf0AjeQ5H5zZQkBLg4NF0+UE
ZBX7mo+Tj1iJlURu41LA7QuGdn3XZgA7+FSQ977ZCxiHqF9M5R29DVtcNj7U5gch
PeiYCuLZTjsn9X+FmiJx5oWcA6ySM0EoxWDqeK6cG4Mw2h3dquN7YDbS58ax0OY=
=8s++
-----END PGP SIGNATURE-----

--Signature=_Mon__18_Oct_2010_18_36_16_+1100_X0fpucxB3q/_ulKV--
