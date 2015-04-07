From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tip tree with the net-next tree
Date: Tue, 7 Apr 2015 17:04:02 +1000
Message-ID: <20150407170402.1aeae791@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/gwvMRf6+qwmveO=jyTZbiIO"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/gwvMRf6+qwmveO=jyTZbiIO
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the tip tree got a conflict in
samples/bpf/Makefile between commit 91bc4822c3d6 ("tc: bpf: add
checksum helpers") from the net-next tree and commit b896c4f95ab4
("samples/bpf: Add simple non-portable kprobe filter example") (and
following) from the tip tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc samples/bpf/Makefile
index d24f51bca465,fe98fb226e6e..000000000000
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@@ -17,7 -25,10 +25,11 @@@ tracex4-objs :=3D bpf_load.o libbpf.o tra
  always :=3D $(hostprogs-y)
  always +=3D sockex1_kern.o
  always +=3D sockex2_kern.o
 +always +=3D tcbpf1_kern.o
+ always +=3D tracex1_kern.o
+ always +=3D tracex2_kern.o
+ always +=3D tracex3_kern.o
+ always +=3D tracex4_kern.o
 =20
  HOSTCFLAGS +=3D -I$(objtree)/usr/include
 =20

--Sig_/gwvMRf6+qwmveO=jyTZbiIO
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVI4FnAAoJEMDTa8Ir7ZwVTvEP/1JuJ3E28pqs1GSrw+FpgQPd
DqxGx9K4Qov8kAze+jJeXa21K7IBNTqSvaA/lBqC0sVw8taSqShQydhBvvYuRb76
Lzcq0Sl6rkCnQG7tC11Tw6jcC2SM0o2G87/oNQHDwzesTEosmcSSaOyejrXWwnIY
fUpH9zWyVjh32n+EBhjG1h02Azn4w0FH/UBTo05lTDkJf0wqEHT7jqlyPYYBFeXV
ofm6xXH9OC1wTLKjkkPOkoPORXpEsBqWaaL5uM+MHdKzVqedPa3fLv1nVWLzR8fG
mvo6luAc7Spugtn0A2qstTqgrG4X8oQ1yq/huAAgKLQLxWrsDcc2EXNlSu9ZOkWJ
YUhjRSUTZ00+3PZM8m7D7/gcEGfzTuH5hc1ca+4PrqITre6j6dMWaXyjKSA2HX9v
rlivivkZbyaj8Ti7PKjwOO/UiCUWJrGjaJI9ZPGlMSUt7bKDMnwQuY4Jat89vT1D
h3vcI0sWojdYvDHmfjLMkNVgSQdyaOaD4HymLS265ArXBp2ikj01SGnyMWmJA/Eq
NZ3/M5dupPoJwgvYEgF/ak8HTOtz3dfvnx6hpMNKP4N0PwWa7T58wHyTku++vi9d
T9yZHyOUogg6tibobfuCdz+lrjUHPhz1jGUC/8vWFdgg6EVpTg7Kb5FaKYsYnhwt
kewehbcDbRcG4ILCs5nG
=wx/v
-----END PGP SIGNATURE-----

--Sig_/gwvMRf6+qwmveO=jyTZbiIO--
