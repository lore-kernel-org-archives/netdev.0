From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the mips tree
Date: Mon, 15 Sep 2014 13:19:01 +1000
Message-ID: <20140915131901.0f3c8a09@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/C.yhC3eF0NnKQDJtoqdZMi_"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Andrey Utkin <andrey.krieger.utkin@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/C.yhC3eF0NnKQDJtoqdZMi_
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
arch/mips/net/bpf_jit.c between commit 98fb24af5e68
("arch/mips/net/bpf_jit.c: fix failure check") from the mips tree and
commit 233577a22089 ("net: filter: constify detection of
pkt_type_offset") from the net-next tree.

I fixed it up (the latter removed the code fixed up by the former, so I
effectively reverted the former and just used the latter) and can carry
the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/C.yhC3eF0NnKQDJtoqdZMi_
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUFlqqAAoJEMDTa8Ir7ZwVbTgP/R//Yqetbd+E9ind02CU8LD9
w3DIbQrERgp8t4+nHCKR3cpNBm8TWVW3qdKUFp0Wv4IyzzCjGiO3f3Y2c7ldP+vC
fBD2Lu1PWbb4tPOQIbHdzMGBObEK3OeyFLWW/q+TBOnRcNeVUeKzhzpCJ3/pU5Jz
UnjZUZ/oX8ZiXnSeWsnEkFbxurRLI4WkmritjsUZRKemjXVSAcuNxmayvDZ5lM7J
AbSeOLuPyo1K47U5/LGxNSEWmgGgRlpwNSTZqPheXrhl/ASCfY1OlgNqRThPjy4l
Q5kVhGY/sJwwWdstyU/TlCrHK1tHGrPIw8daxwqsw0faUvluj7xuGj3UQ8KgjfV6
X/KFdUDYbry5HeQLmj+lk0inbCNz2rTyjk+cidYlT5vQ8KsxcPW3vGI2Iy3lISbH
lhe8r1yRF5R9h67Bhng5zYjFVR97PWUwVSy94DUeBdH874DYyHCa8HIUe5UncKF3
lMjANPGkCt05xSOJeEjUk8awnOAs56Y+ceVCAvgOExyJX3O/JG3GjY+LBuAP+/4/
UIr+RSQTHQByq67KznBnXrhYTuk/t9I3FtLJkpPalJzNFP3yEP/HikcUez22VcVb
v90lFw5toDvujXc+pWooBtK8vnrVFw/sJrQ3/KQiqV8B6yI0Wrc2p5r0sBLqsOND
aF7aZq+zn3I7n0oix7as
=1lP8
-----END PGP SIGNATURE-----

--Sig_/C.yhC3eF0NnKQDJtoqdZMi_--
