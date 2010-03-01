From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with Linus' tree
Date: Mon, 1 Mar 2010 14:20:02 +1100
Message-ID: <20100301142002.ee497fd8.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__1_Mar_2010_14_20_02_+1100_t3pxvQsq53O9YEJC"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	hartleys <hartleys@visionengravers.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__1_Mar_2010_14_20_02_+1100_t3pxvQsq53O9YEJC
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/firmware/iscsi_ibft.c between commit
00e7825b943f486e80ff1305cd0594d8791870f8 ("drivers/firmware/iscsi_ibft.c:
remove NIPQUAD_FMT, use %pI4") from Linus' tree and commit
2c35294853b2e977bdfc9e401b7b6d881fcaa69b ("drivers/firmware/iscsi_ibft.c:
use %pM to show MAC address") from the net tree.

Just a trivial context change.  I fixed it up and can carry the change as
necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__1_Mar_2010_14_20_02_+1100_t3pxvQsq53O9YEJC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkuLMmIACgkQjjKRsyhoI8xYNgCfWmPjw+Vr3aqcIKujWuxmhz+2
ZVsAoLDvoKmvCvsz8bgKwEmhvjpqzl/3
=dIjt
-----END PGP SIGNATURE-----

--Signature=_Mon__1_Mar_2010_14_20_02_+1100_t3pxvQsq53O9YEJC--
