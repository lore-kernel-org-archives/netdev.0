From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the berlin tree
Date: Wed, 1 Oct 2014 11:22:12 +1000
Message-ID: <20141001112212.44f53d35@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/ftAcntMq/oDUWj6ABnmsbtt"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Antoine =?UTF-8?B?VMOpbmFydA==?=
	<antoine.tenart@free-electrons.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/ftAcntMq/oDUWj6ABnmsbtt
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
arch/arm/boot/dts/berlin2q-marvell-dmp.dts between commit 461316fca705
("ARM: berlin: enable the eSATA interface on the BG2Q DMP") from the
berlin tree and commit 75215193b975 ("ARM: dts: berlin: enable the
Ethernet port on the BG2Q DMP") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc arch/arm/boot/dts/berlin2q-marvell-dmp.dts
index 1958cbfe61fa,ea1f99b8eed6..000000000000
--- a/arch/arm/boot/dts/berlin2q-marvell-dmp.dts
+++ b/arch/arm/boot/dts/berlin2q-marvell-dmp.dts
@@@ -46,10 -46,6 +46,14 @@@
  	status =3D "okay";
  };
 =20
 +&sata0 {
 +	status =3D "okay";
 +};
 +
 +&sata_phy {
 +	status =3D "okay";
 +};
++
+ &eth0 {
+ 	status =3D "okay";
+ };

--Sig_/ftAcntMq/oDUWj6ABnmsbtt
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUK1dKAAoJEMDTa8Ir7ZwVtQwP/RJKjWU+wRtI4OdNYxuOQe/R
ZwcgIjXqgsgnZ+/NDftFwq6eOiN7Rt5crxU76Nl4wVaUJwxMC3w12DUdQUa+fX0y
bxCrTEISFZ8f/M596UFQ1pDVktZIvefKK8eKmYY8uwa8nZmGzpCc1J+W2EbdYhk5
4NIfw7vdQOANKg5N3m2HBsnkarkhXM/ky7QTWHscPXFNAFSaLQxB2sHhbUHVbmJ8
pHSpeOpazNgg0d/3BcMxregYUWV4PQn9E1W6I4PLpDylpTG9DMs1SkAy0RveLw+q
0vNshxd709eva+fph6kLcvMTEbFVtj/soeXLzU4A8x/5SF14BFuFs3W1Age38MY3
Sb7IHM2+QbMWa5nkLmrhNeuvjCVGUqBJoiCN+BX1JBI9gggPDE19iODfuCH5kmUl
9/fvUqrmJEM4xJSfe0mcfrhn94I3txX4pPDe5h3yuodPqKJ1jGCe34SkpEDqK3e/
WoXmzaJ3bJMojoXI7Vm90MbiYRSkWD+Y+d6qGW2ACZS7DC1pSAZTZqfOS9nokEL/
namkLG7kW9aQmSEcqphf6t+Qbls2JNHYVqvEvIxYRZ3KyqP729+ipTcM7sK8c4ZF
I8CjvtEYFfmNBT8MFu42RWrZE6rsl0SvAX1SRUfdF2aVDuA7kRGhK054YIJu/lP8
SMSr2ZgvJ1LKkLSPBXYy
=Yj+h
-----END PGP SIGNATURE-----

--Sig_/ftAcntMq/oDUWj6ABnmsbtt--
