From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Mon, 2 Jun 2014 18:36:01 +1000
Message-ID: <20140602183601.65742dfa@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/cJNPMS80ZHeOaELJrIHw7ig"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Mack <zonque@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/cJNPMS80ZHeOaELJrIHw7ig
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (sparc64
defconfig) failed like this:

ERROR: "of_mdiobus_link_phydev" [drivers/net/phy/libphy.ko] undefined!

Caused by commit 86f6cf41272d ("net: of_mdio: add
of_mdiobus_link_phydev()") from te net-next tree.

CONFIG_PHYLIB=3Dm for this build.

I have reverted that commit for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/cJNPMS80ZHeOaELJrIHw7ig
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTjDd3AAoJEMDTa8Ir7ZwVy6UP/1PiE3Q3x3Uy8/0yykAM/jm5
io0m0YSsjoraoi9sYoPgFTAH88hK9CTJed0KEiCm36ZdJ0xxbl77XGC/dU5wJNyO
bJuvLiJ0b/Mcx/ZjIMA1UhRa8DBjHohcnbl2Enc3IzJohc+1782u41xU4kC11u2N
6G1as2BHz2ZFL0YxkepcGXYkQ6czfyLx/v4NxH4dJeBjpH0ZKty2xwUot2i6/WNu
uLJKL6osTl9BhBIVOWe2L9uJfyOFVTCUXgqgF2mJhHD3KSg+wpToc/zoPnPVyxZh
kZAQ8hpuUCb35kiBHQGGX1f2TXLIxRWSOKUBX3dVnkNhuR3VVFaQcheirNGU42s8
MLTTQe2HY2HhwBVXt8klK9m5hO5yp0CdRPRxdGxVRKa7gV9R3gzwyOG3Tp4w4qbL
GbjHBk1/pa8nKn7MzHkqRsG0GptPaxiaWTR+sHLgKLw7nIYWoBUpOwVWsQWXvb/i
buWTIpIRwpAr0Srwjvd6ByczZeIQVyidWpacxSGtCwjUvEgS7r0wxxwEQxMN6IyN
2WKxs3qVZZEghcJnRA1omjwrRULTczbOADXNUWdL42B6gr54rFJ6lau35PJazPOL
2nsuYmOnFvvizcDt5A+ZPw5xaHU5EOIVoh/rd/sz7ecgIQUmldFcbQBxdWuaPLsO
s9pfBQ6jUhoL7H719SsU
=5UMp
-----END PGP SIGNATURE-----

--Sig_/cJNPMS80ZHeOaELJrIHw7ig--
