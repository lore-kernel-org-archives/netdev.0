From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm tree with the net-next tree
Date: Thu, 14 May 2015 17:38:44 +1000
Message-ID: <20150514173844.68c13307@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/TucqpIsaz2=Udef2gVaSCkd"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Scott Feldman <sfeldma@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/TucqpIsaz2=Udef2gVaSCkd
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

Today's linux-next merge of the akpm tree got a conflict in
net/switchdev/switchdev.c between commit 42275bd8fcb3 ("switchdev:
don't use anonymous union on switchdev attr/obj structs") from the
net-next tree and commit "net/switchdev/switchdev.c: work around
gcc-4.4.4 initializer bug" from the akpm tree.

I fixed it up (the former solves the same problem as the latter but in
a different way, so I just dropped the latter) and can carry the fix as
necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/TucqpIsaz2=Udef2gVaSCkd
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVVFESAAoJEMDTa8Ir7ZwVMWkP/jeyzqSovFX+iJzz62R8c9UY
2ddHLqq0t7hS7xhy65+BUweOwLVqBXbnBoKld7RX3T16bYE7QXRkgC6u0EfpGJsz
K5erD38wF8ps/ZaaexXJIDkwmLQGxF0ggemy93qYv+2CNnteX7/zSI5BvwQD0v1U
mySjNmesP/DG98RcWOIuxa7S2x7GPVcHpT+tQyTATVFNXgBCkJpkzizXLPgu5B46
qeBJ7tm9HiCOvKXoCED8eY+TYj4stFe7hkzsbI+8t+LDoDHhjQPwYhXXCU8zRDdB
6yspjgv6Vi+iq7u5RmnsjA3tSBiDHmVoFIEfWUoUBpsQ/wWri9/o3IVjH1783UVg
FIhsctvVYp8oqyi2+kxXozGZafKAAdlH+HdRckAljmcP9QTxL9v0N4XeNdPkhmdL
PBJg3JayE/X+Lqd/eYe7jbAX8eK+gznCotTQ9guk0/42SmAyBaqSf3OTkNcR6OEQ
9vta/178KG8UnEy2Eax+EaNu6aqmFrhTphQ3rp87TY/uOLDobzmloG+1oK+xFg0Y
cw/3ay6EPLaMz63s5NjEzLhUAlSd+58+6JSggS8uueAH+64ro/5TjbB4mBvk2auX
AZgmsHvWIymYhzP2FzBGzPIskUq3u/GN4TuKcxyM6ISqzmsW71+DREaTy48Jo/xW
Mb6+fQqM2vgLkrCsBSGI
=iO3q
-----END PGP SIGNATURE-----

--Sig_/TucqpIsaz2=Udef2gVaSCkd--
