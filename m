From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 12 May 2015 11:49:40 +1000
Message-ID: <20150512114940.3f8f35c6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/IDVcQwFQeeQokdNpOVyrrTX"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/IDVcQwFQeeQokdNpOVyrrTX
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/core/sock.c between commit 2e70aedd3d52 ("Revert "net: kernel
socket should be released in init_net namespace"") from the net tree
and commit affb9792f1d9 ("net: kill sk_change_net and
sk_release_kernel") from the net-next tree.

I fixed it up (the latter removed a function updated by the former) and
can carry the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/IDVcQwFQeeQokdNpOVyrrTX
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVUVw4AAoJEMDTa8Ir7ZwVgO4P/2XGgrQx6pW9VsuKjYDHvgOq
ZByJeUrgxBp04THxQM46rQhUBRnTed3T9KH+qwq0WihjGRQvzcEMJHrOCoGMMiz5
Mqvwx83u7DAqlPvqH+6+bYmDgdwnP2w8MW+2emAXaj0t+d2tTlt01f/sVnr+9AnQ
7Yy0CXCeW37ArKCaxXIjjhhhbciGE2oEhVadJXKJ9UgawfLbDVHVYsLdApQJ+GAp
GmU4C4ubG+QGELGs6a20Mls3DkMa8ErrjNUA0XFN3kk4yjQEoZ9zfTjYOGbUSyfS
LFKxRgyCH9j9m1rI4AKqLuWAa0TNuyL32OZXhfgQx6diEXP/jFXW5Bt0Jahv05e8
bbKTm5Z/YQUP3G+qlRdS7qjLAxaHTrxZiabFyUKIspVgfouHGV+/QZoS9Oxf7vuN
oNTYPi/b3oJGYVDLTDfr1yzI4uad6djIskCG4FAxgiRSy+tSqP7cqgc6SpmnPHxs
Fhod2oEpUVkjp+FJmlMXW8ixhRjfshSchNXw2kjlKJ5OTAUDHlV/Kar0ZcqWWQtw
5/EDfVt4cFc/C4Xw85vM16gehPvoCdnGgxFbCqz1M1+zgaKiGQy59QRj04FhFtBO
0LW5YzNm6/G/NEEQGkLYnXSDndNsUoFRTwvDpqUN/bAB+u/gGnn8AL5kkU6vUlk0
AS5w4TXZZNpgGgPOYTsF
=Y9ut
-----END PGP SIGNATURE-----

--Sig_/IDVcQwFQeeQokdNpOVyrrTX--
