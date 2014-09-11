From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the arm64 tree with the net tree
Date: Thu, 11 Sep 2014 12:16:21 +1000
Message-ID: <20140911121621.4946da46@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/9C7OTosQke2reBX2F=/=u_B"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zi Shen Lim <zlim.lnx@gmail.com>,
	Will Deacon <will.deacon@arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/9C7OTosQke2reBX2F=/=u_B
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Catalin,

Today's linux-next merge of the arm64 tree got a conflict in
Documentation/networking/filter.txt between commit 1d7efe9dfaa6
("Documentation: filter: Add MIPS to architectures with BPF JIT") from
the net tree and commit e54bcde3d69d ("arm64: eBPF JIT compiler") from
the arm64 tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc Documentation/networking/filter.txt
index d16f424c5e8d,1842d4f8ae13..000000000000
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@@ -462,9 -462,9 +462,9 @@@ JIT compile
  ------------
 =20
  The Linux kernel has a built-in BPF JIT compiler for x86_64, SPARC, Power=
PC,
- ARM, MIPS and s390 and can be enabled through CONFIG_BPF_JIT. The JIT com=
piler
 -ARM, ARM64 and s390 and can be enabled through CONFIG_BPF_JIT. The JIT co=
mpiler
--is transparently invoked for each attached filter from user space or for
--internal kernel users if it has been previously enabled by root:
++ARM, ARM64, MIPS and s390 and can be enabled through CONFIG_BPF_JIT. The =
JIT
++compiler is transparently invoked for each attached filter from user spac=
e or
++for internal kernel users if it has been previously enabled by root:
 =20
    echo 1 > /proc/sys/net/core/bpf_jit_enable
 =20

--Sig_/9C7OTosQke2reBX2F=/=u_B
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUEQX8AAoJEMDTa8Ir7ZwVDKwP/R/YlfrBu2DFF7YNLR5Wuugq
KXwcqCZ4FxGyWizO2WPLlyq5KPLttcVs5FhGDBeB1fjVoSgLPGBlotSkaUhRMuHf
4rNCsV7MPE0PutCvKXKMf062WT85AtRhQFotTtREAF1rvanoNbB3FR8Zy5Tqu3A8
g3jDxBPIETw8E7yfQ8sGv5wbXD0cC65mlI1QNtywAi1EJQy4t/Cpp0thCc8QQqDG
XYhfjSimPDFec+z+0DbwilkcwdoS6s6Lw1XCgy5QUB+P2lisdI3H2oe2f3mTjBfC
oMQuFOUv3Vqi12mZCn9dTpkxKvSx1g5UIkX/CylH2k44BHyv4R1YNproAAOYTlZM
o4g0BT6NrQWn67ODDe/Symw9+/nlzdLMzayOL4SLVLRc3SnfwxPZ+rmuszM6sI2k
SPeFhxxmdEduVIqHpVSROg46pPWr3OM2ezt7TzgHfwfDjoJAkXHM9G/BaKnCHor1
vXSCYsBwsbWyJK0itaeyRNRyQSqOXKVTz6sf2IO9ITXOUdNK9yseVk/woKq5LWC0
r70r2bzwmFoXfG1hXEU52XqX9bibDEVQH7faxZtlzZPacRdq1aZ1MQ/hPvYlaT6e
vnZ/y1miOjUR0p0N0c/02JhS8v7ZxroAOV/6ozVBWlVSalbKmD6oNAN8g5b3TIju
tQp0FVG8/tzDO710l3xA
=DGVx
-----END PGP SIGNATURE-----

--Sig_/9C7OTosQke2reBX2F=/=u_B--
