From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the sysctl tree with the net tree
Date: Fri, 4 Dec 2009 19:36:13 +1100
Message-ID: <20091204193613.8986a3c6.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__4_Dec_2009_19_36_13_+1100_zJQ4Qik+y3yrDuzS"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__4_Dec_2009_19_36_13_+1100_zJQ4Qik+y3yrDuzS
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Eric,

Today's linux-next merge of the sysctl tree got a conflict in
kernel/sysctl_check.c between commit
8153a10c08f1312af563bb92532002e46d3f504a ("ipv4: add sysctl to accept
packets with local source addresses") from the net tree and commit
83ac201b4f06eb8aeb7ac93cf162651ba30e0b28 ("sysctl: Remove dead code from
sysctl_check") from the sysctl tree.

The latter removes the need for the former to change this file.  I just
used the latter.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__4_Dec_2009_19_36_13_+1100_zJQ4Qik+y3yrDuzS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAksYyf0ACgkQjjKRsyhoI8yv6QCgu+22/azgw9SVjpdnlo7sJFqf
kb8AoKDfyPVRZ3415pHZ8T+Q9hZ/lx/I
=hkXo
-----END PGP SIGNATURE-----

--Signature=_Fri__4_Dec_2009_19_36_13_+1100_zJQ4Qik+y3yrDuzS--
