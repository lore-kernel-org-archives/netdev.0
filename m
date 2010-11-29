From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Mon, 29 Nov 2010 11:08:24 +1100
Message-ID: <20101129110824.639b2659.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__29_Nov_2010_11_08_24_+1100_EAdUC6t0AXb0tCIi"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Giuseppe CAVALLARO <peppe.cavallaro@st.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__29_Nov_2010_11_08_24_+1100_EAdUC6t0AXb0tCIi
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (x86_64 allmodconfig)
failed like this:

drivers/net/stmmac/stmmac_main.c: In function 'stmmac_resume':
drivers/net/stmmac/stmmac_main.c:1849: error: 'struct stmmac_priv' has no m=
ember named 'shutdown'

Caused by commit 874bd42d24c2a74f5dbd65e81e175982240fecd8 ("stmmac:
convert to dev_pm_ops").

I have used the net tree from next-20101126 for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__29_Nov_2010_11_08_24_+1100_EAdUC6t0AXb0tCIi
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJM8u74AAoJEDMEi1NhKgbsJygH/0/75pGUQg6pDoeSgPaEzFI3
6BQejrhc7rDFFlMz3tjeLd6CUCupfeBRm9gAbK5PfGtjNPtaIYTb0AnUCQvp2rfq
nTodeGmkB6nalkZoKjSNEulRxgYGxVFem9Qd3SVoyXYQ0z1/pBvBeMYGZm2++px3
D3gLloCIiYeo7hbYJ2C4jzm1ueQZPkzbsttu/G9xYJHpeSDydTBYMTQTs+1/T6C0
CkZIDDvbRFaf703JP5GAq2BcksEmkLOFRJ8blQuKk+7GbV9YFjx4dCbmsVrIob6H
YdzGNjMM8XP44BcYWI58FELYKHIQptQZgHqNOX6WXrS0zoDAeFZTrgh2e1sAahs=
=GS1W
-----END PGP SIGNATURE-----

--Signature=_Mon__29_Nov_2010_11_08_24_+1100_EAdUC6t0AXb0tCIi--
