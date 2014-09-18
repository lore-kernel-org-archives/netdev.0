From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net tree
Date: Thu, 18 Sep 2014 10:32:00 +1000
Message-ID: <20140918103200.12b79941@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/ocP2We85YAURodjeN3VYVT="; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/ocP2We85YAURodjeN3VYVT=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (powerpc
ppc64_defconfig) produced these warnings:

warning: (PPC_CELL_NATIVE && BLUESTONE && CANYONLANDS && GLACIER && EIGER &=
& 440EPX && 440GRX && 440GX && 460SX && 405EX) selects IBM_EMAC_RGMII which=
 has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && CANYONLANDS && GLACIER && 440EP && 440EPX && 4=
40GRX && 440GP && 440GX && 460SX && 405GP) selects IBM_EMAC_ZMII which has =
unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && 440GX && 460EX && 460SX && APM821xx) selects I=
BM_EMAC_TAH which has unmet direct dependencies (NETDEVICES && ETHERNET && =
NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && AKEBONO && 440EPX && 440GRX && 440GX && 440SPe=
 && 460EX && 460SX && APM821xx && 405EX) selects IBM_EMAC_EMAC4 which has u=
nmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && CANYONLANDS && GLACIER && 440EP && 440EPX && 4=
40GRX && 440GP && 440GX && 460SX && 405GP) selects IBM_EMAC_ZMII which has =
unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && BLUESTONE && CANYONLANDS && GLACIER && EIGER &=
& 440EPX && 440GRX && 440GX && 460SX && 405EX) selects IBM_EMAC_RGMII which=
 has unmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && 440GX && 460EX && 460SX && APM821xx) selects I=
BM_EMAC_TAH which has unmet direct dependencies (NETDEVICES && ETHERNET && =
NET_VENDOR_IBM)
warning: (PPC_CELL_NATIVE && AKEBONO && 440EPX && 440GRX && 440GX && 440SPe=
 && 460EX && 460SX && APM821xx && 405EX) selects IBM_EMAC_EMAC4 which has u=
nmet direct dependencies (NETDEVICES && ETHERNET && NET_VENDOR_IBM)

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/ocP2We85YAURodjeN3VYVT=
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUGigFAAoJEMDTa8Ir7ZwVN+AP/RY5st6+BAAXfnFIclokBVzy
vOX0xA8RHkvwsv+zHGmFUpJyIEgnA8X7WPxR4l9Q8BCMi5nWounVpObsBSPhZq98
c1E1rf33jwvpkT2d3vN7+DwBB/g2F5A8gRrHzxv9MK5TWet8MVhv7UoCFvRqbdG4
FYu3PhfXw+D4VU9xACZan/312D1yAhJJHLUk4ZfbybqevBUEOXD+aggvm+1zr6Vm
61r1F5B+mo5Yms9goMPmRtchgR8NnY2i3sfRZVwXzTx6CS0OYEUdu4zfZiCHRPIB
jbzZRE2R81DVmi8DW/0zgmnXNImDIpR8/KbMdiq1uxuoeSeQ/rVmp05K/8muVqFf
KtPIQ0cS4HO76VDPzezKyuVRotFe1Mg2eMtVv1kR7t8VY3We8acoe2sb/RinEUsS
FIV5rO2APmkl+dfHgMmEaXjN7dvkrKTVa6OCUuVdYo9hPF1jnVIqG+wpbT6wxRu3
mMFVeMhPoQYlqvxmbRN0lO2JKOctgR1xkXFVl3uYGBE4LOLufu9IsV7cDZF61dHE
LOJcNu/XYf4Fbnes7Fp7jTEVesMWXidnRYdbzz1NblajyVTQe+2DfOfytRtd2xMC
lOiOFVh2ZvrDpJ2VPms0ipzXtrcbGt3VD736o+MNTTZuGoScMEN7bxiq9CX8rY/x
nDMZhXDh+jK2fVwRDZka
=yMUF
-----END PGP SIGNATURE-----

--Sig_/ocP2We85YAURodjeN3VYVT=--
