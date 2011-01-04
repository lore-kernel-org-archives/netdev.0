From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the trivial tree with the net tree
Date: Tue, 4 Jan 2011 14:22:29 +1100
Message-ID: <20110104142229.7aa6b99f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__4_Jan_2011_14_22_29_+1100_/8_j/CFdUkJsWHjQ"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Justin P. Mattock" <justinmattock@gmail.com>,
	"Wey-Yi Guy" <wey-yi.w.guy@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__4_Jan_2011_14_22_29_+1100_/8_j/CFdUkJsWHjQ
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jiri,

Today's linux-next merge of the trivial tree got a conflict in
drivers/net/wireless/iwlwifi/iwl-core.c between commit
81baf6ec9c190ae128748cf2a026bff5cb811b70 ("iwlwifi: Legacy isr only used
by legacy devices") from the net tree and commit
62e45c14fb9a978dca6c7a5dc8372cc8ea2f42c8 ("wireless: comment typo fix
diable -> disable") from the trivial tree.

The former moves the code modified by the latter to
drivers/net/wireless/iwlwifi/iwl-legacy.c. I didn't bother refixing the
typo there.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__4_Jan_2011_14_22_29_+1100_/8_j/CFdUkJsWHjQ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNIpJ1AAoJEDMEi1NhKgbs8k8IAI71YoakYlgQyAfQel4oXG5L
lQTcAYk7E8YYlb6JZcWHj3Vga8kmmOC4FEI4AKL9UOyH6v9Fks8yVDM0ad5bH2rv
v5N2rEvWocgjhqXlH2RWuo9imeOboCBFCRFGPk3gzXMCHlUoNBLdW3GgfNlLI6zs
VD1YeWKwJSmRrPlFhf4KZxIqXx2p6N7T+9Ofsym9G1rJcRbnPAHHgEgauVae4UDU
6S08TiLmvlCL+ws3i0CrLIWM9wgQm+I4BnvA1Ae4z1DT8bfuTg9Ju4g0z6OAYkCY
qoPRk/cYu/DOqLehOoVHPn+Q9IumqfQA9F/NKdEAjoGmved1qyZYvMo2W1Gpdko=
=KR9m
-----END PGP SIGNATURE-----

--Signature=_Tue__4_Jan_2011_14_22_29_+1100_/8_j/CFdUkJsWHjQ--
