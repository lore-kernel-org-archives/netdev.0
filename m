From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 3 Jun 2014 12:28:29 +1000
Message-ID: <20140603122829.4058d1ee@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/YwImn6Loq0he=2k4+8zOj7W"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/YwImn6Loq0he=2k4+8zOj7W
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
include/net/inetpeer.h between commit 39c36094d78c ("net: fix
inet_getid() and ipv6_select_ident() bugs") from the  tree and commit
73f156a6e8c1 ("inetpeer: get rid of ip_id_count") from the net-next
tree.

I fixed it up (the latter removed the code that the former updated, so
I did that) and can carry the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/YwImn6Loq0he=2k4+8zOj7W
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTjTLRAAoJEMDTa8Ir7ZwVeZUP/jo5v89meL/uuiYpiAgJLlSA
7y8BBsYgMrtmQLjdLX4ZiqRhredivfWGHY/7QzdzCfHIBtOUM+cdBUz7O0R9T6hg
VrelTdVB9POMfdseCgi1QeuyHh7TZcTasKQz2nsV8AJ3zyU64111w7jgF9RW7wJv
ZGJu0TaEqaNzjcdR/eGvFYILElr6V7KLd8QjrcDZKpZxMDkBKesyrdVcEzlKYhNe
ykqWLeTDCPVgjWXmTg23k21Mxv54cKFmKJ4ui5hmv9aH+yavZ6AFinqcKAQgaGaj
HjQITKbsNLTXCYbP0IUjTvuZ62FAxkMzhZ6nza6DGYT6n528eMzZ0DsV/UnMy4PR
E+hXCANuk+KAGueCRkkiyrG1yB4HdaOlUALOhAYUxRXh4MhyBb8A2cL+OBWZ3KBG
b5+hZK7dh4n9q2+DtsqasnVghYmzbR3AiiHESiftOiNPEOBUJK8FZ6qnioby1G/k
RRWZZLFbE8jP2sVletD1D7lo2uyGVGN8eEOm2DLYCmvglCNN2zrh02fxQDNXsa9l
Q0A2LF+BQhDWhHDmtVjgPPYIO/1/i8ildQfzaSscHTstyD3PuFwUtvGvhqEflHww
273a78UP0NgbiQap76YiKZjSKS9wpW5hFzsl1Lk07+QFIdasV+2/d+wQlBlLG4Jp
jmihKm9Ec9nGKa7GHYfX
=UgTG
-----END PGP SIGNATURE-----

--Sig_/YwImn6Loq0he=2k4+8zOj7W--
