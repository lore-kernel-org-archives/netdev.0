From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the sparc-next
 tree
Date: Wed, 16 May 2012 14:39:44 +1000
Message-ID: <20120516143944.57a648287aa5cd1a5930254e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__16_May_2012_14_39_44_+1000_sh4o5juZ641LbFkQ"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sam Ravnborg <sam@ravnborg.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__16_May_2012_14_39_44_+1000_sh4o5juZ641LbFkQ
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
arch/sparc/Makefile between commit e1d7de8377e6 ("sparc: introduce
arch/sparc/Kbuild") from the sparc-next tree and commit 2809a2087cc4
("net: filter: Just In Time compiler for sparc") from the net-next tree.

I suspect that the core-y net bit below should be changed to be a obj-y
bit of arch/sparc/Kbuild ...
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc arch/sparc/Makefile
index b9a72e2,0e5de13..0000000
--- a/arch/sparc/Makefile
+++ b/arch/sparc/Makefile
@@@ -52,8 -64,9 +52,9 @@@ endi
  head-y                 :=3D arch/sparc/kernel/head_$(BITS).o
  head-y                 +=3D arch/sparc/kernel/init_task.o
 =20
 -core-y                 +=3D arch/sparc/kernel/
 -core-y                 +=3D arch/sparc/mm/ arch/sparc/math-emu/
 +# See arch/sparc/Kbuild for the core part of the kernel
 +core-y                 +=3D arch/sparc/
+ core-y                 +=3D arch/sparc/net/
 =20
  libs-y                 +=3D arch/sparc/prom/
  libs-y                 +=3D arch/sparc/lib/

--Signature=_Wed__16_May_2012_14_39_44_+1000_sh4o5juZ641LbFkQ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPsy+QAAoJEECxmPOUX5FE73AP/3CMdlPoW7O3bkGdjOTms1iV
XGed9TMVvF0Z5lok4SXP5w2JNpRU2iJEdoCEzdITWlGAx/CWZoKxT8GNCMLCimg8
KskK3cNHl42QFdk3AWg68VP5PiQuzHX9xlPdrRJ6suNL5fkCywHSgLjLW02AAZN8
OekmjrdQlkkJtE6rUNJsvGt5Um4Xlku1ht5Je/eARVtocA7ge/rXdX6bo+YwDpWA
xz3OU1ISVr0ul58sSPXjtP2jfNJXTE59/FA8WcIPf5qaw+cIn2RyADrTLnWZsmkg
kqm0J1yhoR6/qU2GGqLX2yTXIpsIIxQO7vjfVr0S/7+BPV5nC6jshtHuCgtWm//m
rzIw/QOSUfpuRhZP/obPnAG0q+kZplk5JGDRQluVza6977DyV0eB8KgEGm0R3Cxl
JkrrnF9o40MiDTZ66CucA9aIIOBWsNxKpaECLPSY60v9zfHwady1zKIbcGzrJXYU
tXeA+yULRsNHz40+P4qn7hVej/w/ttrMyyLtR+lpFAjS+gQIJpyhgvEQcpzUc6bu
v6BgMrmY55ZSiLeVKeRJ+rFoYYb7mICXmDn/HcBlWPeYEI6ixQJXT93lYS4oK7aA
N6NH5yIknG/0f9+hqIrHCfmeyD1VhYnWRz2EfUz2ZF4ZsPDvjooNiF47t1Yyg8DW
XkKCJEcfb0KAKfqXB3bv
=f/lU
-----END PGP SIGNATURE-----

--Signature=_Wed__16_May_2012_14_39_44_+1000_sh4o5juZ641LbFkQ--
