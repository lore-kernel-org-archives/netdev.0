From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Fri, 28 Sep 2012 11:43:35 +1000
Message-ID: <20120928114335.e05b34a5cfe716df86364ccf@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__28_Sep_2012_11_43_35_+1000_W.X_4H_ep0gCWGHB"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ivan Vecera <ivecera@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__28_Sep_2012_11_43_35_+1000_W.X_4H_ep0gCWGHB
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

drivers/net/ethernet/emulex/benet/be_main.c: In function 'be_find_vfs':
drivers/net/ethernet/emulex/benet/be_main.c:1090:28: error: 'struct pci_dev=
' has no member named 'physfn'

Caused by commit 51af6d7c1f31 ("be2net: fix vfs enumeration").  physfn is
only defined if CONFIG_PCI_ATS is set.

I have reverted that commit for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__28_Sep_2012_11_43_35_+1000_W.X_4H_ep0gCWGHB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQZQDHAAoJEECxmPOUX5FEiR4P/3dRvjeRVC5rZtH/3LeWx+p0
f6hWFmqLRI/myBRSaWuiZRkBfp9R5gNq+RtkriMjIOAxyClJQ8RWUOU91Qt/nRYr
06l7urqyDw6XEbgPPHlfBxQ5YpH422OWBA/iAZPU1tb35AMqXB/rkf5HyRVWqk+R
xwTZbon1wsM4Psdk9mcULaA68iLTp45d+FhqvxtEcdE5wF0i7MqmLeRSYDmGlgIl
d+h5XpSp9LwtCyuoj+xPuTIBeCe8/1w+Bk55y6TPp0dS+UxnHElRZ9/AQxksTS1C
BoYv9Aihqh4duWTmTgJzaNf5dcyEZvM4rqtiDRlvLyciEipiSdUp1vtS15qtiqRO
piHOXCAYEBp4dtNuE5CETKLITOp5kjOcNpdin4rNytU7lGj5DBjYnQX/6xHX+SGd
nVloOruSYbWBBBwQIb2DZz1te/sk8nhwEsMDbNaqA5yxxddW0RYgP4acLglfbBRu
0tjb0TNq/VwF2Iz//VGL98OgyPaQM+qIGBeQB/wnh1ysJ3ZvvFc884jXmDS6xTks
WARmytg6alNweVNriCrexCP1m4AqfvpSZFeOOIbHKx0Ato6iB2DML/ZhJitxEbwa
D/p4mJdFLgMMnXuUM/uiyQ60CUCdpsFEkwV+knFbK6KMD1p7s7UbzN/gptXkkvF/
X8mKciWINuf0iXqA8DIE
=HlIb
-----END PGP SIGNATURE-----

--Signature=_Fri__28_Sep_2012_11_43_35_+1000_W.X_4H_ep0gCWGHB--
