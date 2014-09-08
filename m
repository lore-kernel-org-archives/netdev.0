From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the rd-docs tree with the net-next tree
Date: Mon, 8 Sep 2014 17:59:13 +1000
Message-ID: <20140908175913.42603191@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/ubLhkEWkDM/WYMowOA=QCiz"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Willem de Bruijn <willemb@google.com>
To: Randy Dunlap <rdunlap@infradead.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Peter Foley <pefoley2@pefoley.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/ubLhkEWkDM/WYMowOA=QCiz
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Randy,

Today's linux-next merge of the rd-docs tree got a conflict in
Documentation/networking/timestamping/Makefile between commit
8fe2f761cae9 ("net-timestamp: expand documentation") from the net-next
tree and commits 429cbe7863ad ("Documentation: use subdir-y to avoid
unnecessary built-in.o files") and b07a884ea14d ("Documentation: add
makefiles for more targets") from the rd-docs tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc Documentation/networking/timestamping/Makefile
index 95e239c70076,52ac67da9315..000000000000
--- a/Documentation/networking/timestamping/Makefile
+++ b/Documentation/networking/timestamping/Makefile
@@@ -1,20 -1,8 +1,14 @@@
 +# To compile, from the source root
 +#
 +#    make headers_install
 +#    make M=3Ddocumentation
 +
- # kbuild trick to avoid linker error. Can be omitted if a module is built.
- obj- :=3D dummy.o
-=20
  # List of programs to build
- hostprogs-y :=3D timestamping txtimestamp hwtstamp_config
 -hostprogs-y :=3D hwtstamp_config timestamping
++hostprogs-y :=3D hwtstamp_config timestamping txtimestamp
 =20
  # Tell kbuild to always build the programs
  always :=3D $(hostprogs-y)
 =20
  HOSTCFLAGS_timestamping.o +=3D -I$(objtree)/usr/include
 +HOSTCFLAGS_txtimestamp.o +=3D -I$(objtree)/usr/include
  HOSTCFLAGS_hwtstamp_config.o +=3D -I$(objtree)/usr/include
-=20
- clean:
- 	rm -f timestamping txtimestamp hwtstamp_config

--Sig_/ubLhkEWkDM/WYMowOA=QCiz
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUDWHWAAoJEMDTa8Ir7ZwVLKQP/2pDg7ZUUQaBG14pqSJk6H3/
A9I5c1sve+pUcLOmJyUSEDZ6etd4s25nmTS2e00eGnFv7mcrefMMP4E547f8tYqg
5dK1WZzRTB02AGWjq41iRMbscipxFpEGkPeaNCOR82EYOXeVysVyREpXuPX9jD+N
R73/y+8ilr/z1UbvtJAe0Rm6Jnsh5nthJ0KPW3IN3iYtgICrGIlTMIaMPg3zxNnr
dAqoZMg6PlCOzxoJxgETq1Yi84CCVZ08Q/BCAc5aX+4ezNj45TnbuS0xj8jECOiz
1X2r1w0thbbFKDMP1l1vXzDceuJ3VpMCzfXYVIFkXKZRRS0fst3/e5zpqqB8ehxO
Zhn0boNpSFG7uC6qmUt2vazzAtVy68IGDq2d/jITCI1YjKmOrCPEZuiRefCLnE2k
BU7LtA2e2FgluQ4woLGvwTyBaRaVZiIuZ6FPn/uEs9arYxm62JarzFeJdbNeLztC
OBb0kwkw5GoSoY7ZxlR0haOk5X/E++Qyjg1sKFcFg7gUy1PVWDRLy3mLPKrU/U6d
KKyqzj1vFRPdlsl3bD0+Oyo0Y1k4b24VLMaXttkv5n87V/vA4AoOW7M31YEfAWaX
H+biJFBKHvYVClOSCIJJLbpPIetg+s8QlnBvDD/MLO5BJ/OMIUTabq3Qy5M08T74
S3z9GBTs0pouZL8IwpZq
=GC/k
-----END PGP SIGNATURE-----

--Sig_/ubLhkEWkDM/WYMowOA=QCiz--
