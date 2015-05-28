From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Thu, 28 May 2015 14:17:16 +1000
Message-ID: <20150528141716.562c15e1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/+Remyv7KL42dMqfHdAXGuPF"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Lendacky, Thomas" <Thomas.Lendacky@amd.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/+Remyv7KL42dMqfHdAXGuPF
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/phy/amd-xgbe-phy.c between commit 983942a5eaca
("amd-xgbe-phy: Fix initial mode when autoneg is disabled") from Linus'
tree and commit 7c12aa08779c ("amd-xgbe: Move the PHY support into
amd-xgbe") from the net-next tree.

I fixed it up (the latter removed the file, so I did that - there may
be more needed) and can carry the fix as necessary (no action is
required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/+Remyv7KL42dMqfHdAXGuPF
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVZpbQAAoJEMDTa8Ir7ZwVhQMQAJEVV+nVAR+n2+cEPrnDxN8K
1J1datB6mVfjzprzhONCbkf7iMtebk7A02m9BzLjY8BOMygcrOI6aWlN1wp0SlG3
SpIYtBzNGCZcQWEqHaF6sWaJrL9/mnZ4lvZ7k/nJykOJJWaNB7Z0aOXmNhwHCyUF
99/BA8yTaPSj+gefVX1Uc7k9nzgx+jJfwBn8yK84rT+nEq+fqb3+UMLEI6LAl31V
kcIDz7YrHPeO8LAsyf8RvT1waBk3XADN2NdLFrimtMAueVUVFdwDQdUJ7uRV8x+t
oqWIEPQchq9oMim0rz8S4iB+xwdBYi/iliwv+tLnJT0Jv9/NVODEHE1/jDsoqsi5
ftURttZ+7N6dkehi00ewaptb58nBf7ytBjv6kHso9Tg6f2cqHIjptoP010EL2Gzv
MzNOOQC1cKXeLH6k1jSlDyxY/ZfJlRA/8cqmoRUIdF4k1qkFwQItAzNDZ0pfQ03x
+0KeCInzfZVBwHdIX2pgyZK4a0G8FQlp5ksNZuQXDCXrX/naEHUx5e+xk3aWs/66
/tLVoYdd4GFPbByq/CJbju7YtqA3pXiF7fDl5vLUlb5IQZBmFj7rM5DyDrk5X/oB
l39/XDQ1y+EfskCqvopS84uSuEMsRB8OM3hgg3gEaA4kWAHttbPxbSro9JjLlhJf
1mBwU+x43qz+LtGSdr6H
=dFlk
-----END PGP SIGNATURE-----

--Sig_/+Remyv7KL42dMqfHdAXGuPF--
