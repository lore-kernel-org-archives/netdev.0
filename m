From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Thu, 20 Sep 2012 17:36:22 +1000
Message-ID: <20120920173622.2aa7209cd241a3945f4384d4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__20_Sep_2012_17_36_22_+1000_OR2iKvAWGf=5rQZb"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mika Westerberg <mika.westerberg@linux.intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__20_Sep_2012_17_36_22_+1000_OR2iKvAWGf=5rQZb
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

drivers/net/ethernet/i825xx/znet.c: In function 'hardware_init':
drivers/net/ethernet/i825xx/znet.c:868:2: error: implicit declaration of fu=
nction 'isa_virt_to_bus' [-Werror=3Dimplicit-function-declaration]

Caused by commit 1d3ff76759b7 ("i825xx: znet: fix compiler warnings when
building a 64-bit kernel").  Is there some Kconfig dependency missing (CONF=
IG_ISA)?

I have reverted that commit for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__20_Sep_2012_17_36_22_+1000_OR2iKvAWGf=5rQZb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQWsd2AAoJEECxmPOUX5FEf8YP/RMOnhYeXVHPZxPj8JO1Mkkt
1Z7czcmR0yDt5vnO/XoCNcNWfCLTGuSClxonTmUmx0IofYgMgVe17ww+c4DcdWkU
txcT3sw0UjI+nthzvkmuhjgNoU3f/wC8Z/MgtS9H10CEqJgNGQ0slQitIJ4DaAAl
9HGWVP0a/2Mzwh+RLU7yOValMP9DogDRFoXIIyjhxWi5LOfFu9MJ5EQfAhBLXzTo
hp+vsaLJEp8T9kTQyZrt0KredzAOsaKi3q1vSH7NXSpWlsfMcIWffs3fWz0CEEaH
6SF7awfG9vzR1+oaR6n0fxgIJGM4Iz8mLfNdFXiDrsdpAnyEfX/hi8yD4wgb/xGs
SRYEtlJU1gXFF07g5R93S9fTC38E658GhGYkoj09p1/oAH3dCXzwmDWtOVCUQyIu
YdgmbETCxcjyWgv8Cl0bYEE2BB123HgYJQTHlBotCBriU1InFY5t0PDGjEjjyBkC
qM7Y4ZiKJ6Ffu7aBLBlK1SA7euP94+B3mC/y6pBRMN5pn2sezw0GaQ3FQynL6zEo
DESuHQXk20qD2k6eyIOUdLU5HJsDpjFuIi6anZ82jTT+qPiW2cTiC1xN7PqBjCEK
PKE5H47Q6TNNawmVXuGVSo7meHzTTSKBSKD9QrsMEen4cVrLnawms/D1pbCE3+0V
IEf5/N8ZhRj/pkD4K3M2
=SUiP
-----END PGP SIGNATURE-----

--Signature=_Thu__20_Sep_2012_17_36_22_+1000_OR2iKvAWGf=5rQZb--
