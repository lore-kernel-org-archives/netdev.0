From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm tree with the net-next tree
Date: Tue, 21 May 2013 14:32:25 +1000
Message-ID: <20130521143225.c74bc044cc1e6d4cd58bf317@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__21_May_2013_14_32_25_+1000_rAog1/ij4yVJyHf."
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__21_May_2013_14_32_25_+1000_rAog1/ij4yVJyHf.
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

Today's linux-next merge of the akpm tree got a conflict in
arch/powerpc/net/bpf_jit_comp.c between commit ed900ffb73e3 ("ppc:
bpf_jit: can call module_free() from any context") from the net-next tree
and commit "bpf: add comments explaining the schedule_work() operation"
from the akpm tree.

The former means that the latter is no longer required, so I used the
former and can carry the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__21_May_2013_14_32_25_+1000_rAog1/ij4yVJyHf.
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRmvjZAAoJEECxmPOUX5FEktoQAIcy4FTNJN4mndwfzuzXmJAl
CowQYwihu1Fs8IzuMlDNy6R4Ikg/RH993d33KdLk9lynJxO2E3xk4/VOGJ97WdKj
h0xN3fi4JTsOMJLPVLJVpym651hm4ReVtCgA3ZcnC/sZnbCMeHNDil0WRVnHCTXs
CCQ9IuzgQTFgEJeWJJkVeRoaBG7jcq7A5A1rMHINJMlW7DZ2H91+vK/By5w6nHGb
TMhk9/g+EfRXdbCAeDwgWG/XX9lI25mWMPrPBlQRddmrzkRFcFaVrrm8vSMfmqfi
9LuakNF5YWOfSjHkgN4CkHgHlVwHyjaZVa0LMKdKodkdclVkCVdnke5eug0OnOTh
XXfImKPY9WwMpHKNGcUKTWyLi6ylpbNak1LHkSSahe6/xmtH8a7dX+gjW9/0B4gB
tHfgRCsL7NgVsN7ZYGsj0B+sZ/eRkykM179reLOlWLd9Ij6d5EinZDSky0qcTSpb
6UyFqWPkLheUU37yPY85x+sjbhPwjrgftVzsIBlnfii5c3+wKVQ/bK2zBor9hYKR
dj3U/Dhzu/vJCor8AVUwymk72F0wrp12+KdfXz1bHRUmwOOYbUSVLlAF7I8F8/hU
5IcJk65/6id8bZxByzJ83ysJvMgJAn+/EqZxK3WriX1LPK7JFQI5qP0F8J6zGnot
NwBuxn1Gl5msKU9DzGG1
=txY1
-----END PGP SIGNATURE-----

--Signature=_Tue__21_May_2013_14_32_25_+1000_rAog1/ij4yVJyHf.--
