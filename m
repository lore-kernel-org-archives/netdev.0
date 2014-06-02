From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the infiniband tree with the net-next
 tree
Date: Mon, 2 Jun 2014 13:46:18 +1000
Message-ID: <20140602134618.6cb5e747@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/mRobN0mJrb0Au./P44JdCYQ"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Roland Dreier <roland@kernel.org>, linux-rdma@vger.kernel.org,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/mRobN0mJrb0Au./P44JdCYQ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the infiniband tree got a conflict in
drivers/net/ethernet/mellanox/mlx4/cmd.c between commit 1a91de28831a
("mellanox: Logging message cleanups") from the net-next tree and
commit 97982f5a91e9 ("IB/mlx4: Preparation for VFs to issue/receive SMI
(QP0) requests/responses") from the infiniband tree.

I fixed it up (the latter seems to be a superset of the former, so I
just used that) and can carry the fix as necessary (no action is
required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/mRobN0mJrb0Au./P44JdCYQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTi/OOAAoJEMDTa8Ir7ZwVfb4P/R5DOcfR+0KLeYvHxiNltReC
+Ypw1fr48KcayqHuLBwnwncz8t9YmOopTAgoZuoTX7YSRnrskzDW7+5Gl4uV3iqB
bBXBpq2uAJx4FwfMHqmAVwTZYLHLo7kyeXHmemZgdqMRpqEZZgJKCbK5KwaEG2fZ
UbRJM57DGViFqEnncoR7RpBAHFP+prd7BXWKzUYe48Z7HjtiQTCG533XMnST+hXM
5tjNVTrd0fWoJyHp4GdUy50ymryYwmfofsharwYEEbxs4XVoNETnyWXp8cDxZMoN
2Fdk56Xu1RX+tBNIPT/jO9wf88GAhfGJDAkwm37Gk9bz+myy2qxFf/YuDJCa80HQ
Dhe+GDLyDV/gtI1e3xvzp/3SJ9i3NXrkxq8Yy4pxAtmCMUwatxDMieIjQs1fbOhd
iEQyHjpSQGHY8nLrkl2E/6ULqkqVoehpY2WCk4jIaayxeD8q8Zq8C27gmsIvwWNs
l8EUh+925pVr+XlQqA5tDnw9QhTKDNW9aenIpQY97hqdlPdKqPmLaxMPpJeok+12
5GzyCYFeM89/aNA9tlrMx29zH26hnRZ/h1G7QVEOGjrWAvp7wgSXIwnmjZMNFIWO
1QcgwvU+xn5C3P3ihlTPCzlXJuizMsMlIQnGdmCNDwd5cQYX26sqU/sVZ64G9/zP
leGrj7Zu21M9oSHQ7L9+
=aVAm
-----END PGP SIGNATURE-----

--Sig_/mRobN0mJrb0Au./P44JdCYQ--
