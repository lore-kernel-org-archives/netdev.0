From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the origin tree
Date: Mon, 14 May 2012 10:44:52 +1000
Message-ID: <20120514104452.2411b761e8f98076d1ae88ee@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__14_May_2012_10_44_52_+1000_nn5NlLWeccAn5.r5"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jiri Bohac <jbohac@suse.cz>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__14_May_2012_10_44_52_+1000_nn5NlLWeccAn5.r5
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Buildinf Linus' tree, today's linux-next build (powerpc ppc64_defconfig)
produced these warnings:

drivers/net/bonding/bond_main.c: In function 'bond_handle_frame':
drivers/net/bonding/bond_main.c:1463:13: warning: assignment from incompati=
ble pointer type [enabled by default]
drivers/net/bonding/bond_main.c: In function 'bond_open':
drivers/net/bonding/bond_main.c:3441:21: warning: assignment from incompati=
ble pointer type [enabled by default]
drivers/net/bonding/bond_main.c:3448:20: warning: assignment from incompati=
ble pointer type [enabled by default]

Introduced by commit 13a8e0c8cdb4 ("bonding: don't increase rx_dropped
after processing LACPDUs"). recv-probe in struct bonding is a function
returning void, but the local variable it assigned to/from has been
changed to a function returning int ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__14_May_2012_10_44_52_+1000_nn5NlLWeccAn5.r5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPsFWEAAoJEECxmPOUX5FEM5gP/2/TKpRgct74/l9s1WOFDD8Y
OjBBQJRvsWzc56bhI/sJoc5MFW+yZIO/aFDGJk1b0+4dks5wnWyfgZyrns9TuDti
ca1zWa8EJH441SMbh6HdDl4o0D0Hl+XwV0zHuyOJX6i4v3JsDmoateFXYdjDMGka
ZHX7yxjcbH7W3PUpt/6fWb4+4QjmCAEGTUG881HxzJ7gxfdZtgMx72wWjI4GmTsi
q3oxlajhEtiNd41viqkp+Be4UZR3W6i0SjKaBcWAOZVPS0xtlcUOKZECk44jWs+D
I6b5DrFXTiol9b7yw2tvBjVc6l0LtnPnZFRJ9JEc62pdP7qiJLVMuAzlm/iAyn+A
V/2T3jbmnoWOd8Xj4N9UTwSn0N4bn/gxvVKk+0xJHgIpqfHtIqoQMGtOPkW7cbXv
f2LqtVt121+8Sk83u4qgR/JMP+jAhf41wxFLzwNy3e4NRPv5ojFu1VKmxJ2sg5ua
OPMgIaDdwiEPqTrVZJxVPJJv36NWy/vqa3/GwsX38Af/0PKkODh6zeBfOl5b64+q
4TmyVZ4jQF+llHrIA9vfZ9yhuxl9+GY9TpaJFh6OcFMm8SzSrM87p9YVOsvfm/4u
JUXLs/rPxdYaJFkbdvLbRf8PU3DE4/a3lPzhbzMLymfpwDbhOT74ceewlQNRX07x
K/KkmfJIuTe8/6ryiix5
=lpOb
-----END PGP SIGNATURE-----

--Signature=_Mon__14_May_2012_10_44_52_+1000_nn5NlLWeccAn5.r5--
