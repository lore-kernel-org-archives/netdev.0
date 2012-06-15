From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the wireless-next tree with the net
 tree
Date: Fri, 15 Jun 2012 10:23:10 +1000
Message-ID: <20120615102310.a066ef60ba1c3c083f078aea@canb.auug.org.au>
References: <20120612114129.68159847828093544c867306@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__15_Jun_2012_10_23_10_+1000_pCGYjChD0K1uUYW6"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Johannes Berg <johannes.berg@intel.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120612114129.68159847828093544c867306@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__15_Jun_2012_10_23_10_+1000_pCGYjChD0K1uUYW6
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John, Dave,

On Tue, 12 Jun 2012 11:41:29 +1000 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> Today's linux-next merge of the wireless-next tree got a conflict in
> drivers/net/wireless/iwlwifi/pcie/trans.c between commit d012d04e4d63
> ("iwlwifi: disable the buggy chain extension feature in HW") from the net
> tree and commit 4beaf6c2f8af ("iwlwifi: s/txq_setup/txq_enable") from the
> wireless-next tree.
>=20
> I fixed it up (I think - see below) and can carry the fix as necessary.

So this conflict has now been fixed up in both the net-next (commit
43b03f1f6d68) and wireless-next (commit 627ae3ddd6f9) trees, but slightly
differently :-(  I used the version from the net-next tree.

Just a heads up.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__15_Jun_2012_10_23_10_+1000_pCGYjChD0K1uUYW6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJP2oBuAAoJEECxmPOUX5FEsNYQAJpn1R8C2NFiDaC8+4ismOzW
5+96Xj8gdpRASRAkVjnD5+ZgYacw/H3VibsSBR1ez2nvjcmIY3GtIJIxSxkHBDpN
fmjU4EZcbtMoQwq8CnCKVIfe2PZ0vhtR5g4vftZ/y9aVDi9DcWCU/bXux0qWUh30
h1F7+A6osz9/KgTi+aBYoTAKdLnjnl85H2LyfH7lyWbrC4zEWcc8tSH2fjNRVdxq
r1J8BbJmlKtLeHp8qKWFFQLWoSvgIjWTHFxpVqwtG3G655EvVp4Lm5VfIt9NLTTT
C19m1CsIIkBZw8UGZ9YEvPjiJbIKewFRVBdDxMFbDLg1ycJf7aGtMoLrCkf0AoyI
TmCUY+44PQVEtJiwu6SNOzTKU6ZdPG/js4PGhe4ZiIvMiqVK1F+RMt5NW+xqW2pl
oqhGkgBdIikz4XOz5zT6J8rbUsyFdpn80zQUAf2Z7OrSjmItEAJVyEFXTKgX57Y9
TdTxlJ99nh3OaK8T5vlCnhKqPhsg6QxXFTAp8nX6m3xc8arujbgqqQ/zQpXRvGWI
Fy6wed7F1MtK59UorLWriQdMP5xdoR17QjF90hiUL9yy9Dfkt13WF1oAi342wBem
vcGCVlna//bMn2j9Cf97PWPpxalxg+tYMl/qwSCYM9EP6bqc+v7fDEpshv1X1Yyd
FMevpyZLmMLl6Y4mUZMC
=DIPV
-----END PGP SIGNATURE-----

--Signature=_Fri__15_Jun_2012_10_23_10_+1000_pCGYjChD0K1uUYW6--
