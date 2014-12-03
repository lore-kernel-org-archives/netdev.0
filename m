From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the
 kselftest-fixes tree
Date: Wed, 3 Dec 2014 12:52:38 +1100
Message-ID: <20141203125238.48fa7380@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/+PSmxa3y_RuCJsG7Uphl6rI"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Ellerman <mpe@ellerman.id.au>,
	stephen hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Shuah Khan <shuahkh@osg.samsung.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/+PSmxa3y_RuCJsG7Uphl6rI
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
include/uapi/linux/Kbuild between commit 3f4994cfc15f ("kcmp: Move
kcmp.h into uapi") from the kselftest-fixes tree and commit
df32dd2054b6 ("uapi: resort Kbuild entries") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/uapi/linux/Kbuild
index d78fecf216bf,a1e8175cc488..000000000000
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@@ -211,12 -211,11 +211,12 @@@ header-y +=3D ivtv.
  header-y +=3D ixjuser.h
  header-y +=3D jffs2.h
  header-y +=3D joystick.h
 +header-y +=3D kcmp.h
- header-y +=3D kd.h
  header-y +=3D kdev_t.h
- header-y +=3D kernel-page-flags.h
- header-y +=3D kernel.h
+ header-y +=3D kd.h
  header-y +=3D kernelcapi.h
+ header-y +=3D kernel.h
+ header-y +=3D kernel-page-flags.h
  header-y +=3D kexec.h
  header-y +=3D keyboard.h
  header-y +=3D keyctl.h

--Sig_/+PSmxa3y_RuCJsG7Uphl6rI
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUfmzwAAoJEMDTa8Ir7ZwVzdEP/R2dC4soe0tC9SXyYdOUzCZe
/6Ajh6yFu21DHZM5mkaR6DhHSUYWjX1nnUt20VxhueFUhVIe9ImE37dgs7AkNRoU
fWtBz2tfbklWnleIrbuoarAeVtWdn603O2IV/bari51pbHNGbcHv3FyckHUEEnEo
8GHtHt7rEAqQ/LStF4tBXtbqoH+NKateRdRf9vV7rgVX+6gRrfIdBglvEGTcME83
HxUCE8NJA3bkCdaal+PkPP7HDqrNFfnTkT2EsFKaRfFs4YSEy0/6Xx5PLzp6No7a
FAjmWf8Wxxxn33eJCjUEI9YFpfWYKmITOugtlVMGx8UtfQ6qwVfq0gw6MxR5Ru4D
vMPzmFs286rQpvyulO44Ns04EFTQYasFHrOj2RWbLhOfO38EqjUK2I1Zo4p6Li+E
CGe2Njxy5gkiU6DBIMKnakFwBWXrIWnEB7HxvUvcWrcq8QIjqx39udc93nEKqQWz
rwraArb3JEdCaa6mVchHPfuhsferLIN3xHPPuh30GIqO4k7sOabAi/WR7QiVRhoq
1ZW6pwHQYtKU3i+7Ik8q70/gGDnK8sidtdBmqumfQvYzh7z+eL72tRtVNTzE6/fw
QSDK0oPBlwWScyRwKRvsv9s1sFllYoA4F7kf8MXEJZweAtgrKpBAJVWGqb7C+KGU
TlMKk1LlBj3RS1mab5uL
=y44f
-----END PGP SIGNATURE-----

--Sig_/+PSmxa3y_RuCJsG7Uphl6rI--
