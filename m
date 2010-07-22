From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the  nettree
Date: Thu, 22 Jul 2010 12:06:39 +1000
Message-ID: <20100722120639.cc8d56a5.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__22_Jul_2010_12_06_39_+1000_A+Y/vdu.lzS0Gq1l"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	Florian Fainelli <florian@openwrt.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__22_Jul_2010_12_06_39_+1000_A+Y/vdu.lzS0Gq1l
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

After merging the net tree, today's linux-next build (x86_64 allmodconfig)
produced this warning:

drivers/net/r6040.c: In function 'r6040_ioctl':
drivers/net/r6040.c:513: warning: passing argument 2 of 'phy_mii_ioctl' fro=
m incompatible pointer type
include/linux/phy.h:522: note: expected 'struct ifreq *' but argument is of=
 type 'struct mii_ioctl_data *'

Introduced by commit 28b041139e344ecd0f144d6205b004ae354cfa1e ("net:
preserve ifreq parameter when calling generic phy_mii_ioctl()") (which
changed the phy_mii_ioctl() API) interacting with commit
3831861b4ad8fd0ad7110048eb3e155628799d2b ("r6040: implement phylib")
(which added a use of that function).
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__22_Jul_2010_12_06_39_+1000_A+Y/vdu.lzS0Gq1l
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMR6evAAoJEDMEi1NhKgbsMp0H/2/4hpmW8EHFeoyA5v6L2lfl
FbiRmU/tVEja4RLlz1sAUV5BgvYWeibmmy0/srNnC84DEMk+chQp1xS3pU2ONyFz
HqnUJoXsgJcuVQJTbrcr+cX265czLbRRUAXf463OZvYLjJi8OIDB5jGnlaFEUtNm
F8JkrnndCxJgE803QPJ8nlR3akkjb8Niv99Tn2prh+m7hw3WCx3lZ3gFGSUis9+A
g+hrQq1zJUvXjzzOImLHLf2FN8LjBQFdDavRLik8FvqvCnY1SEHt30fQeN55TI5h
3KDZm9pHmxs16wiDYK9NQfcibOoX9l+nE1t74+odHcoUeH95twczC0o4VLdAVqA=
=DhRj
-----END PGP SIGNATURE-----

--Signature=_Thu__22_Jul_2010_12_06_39_+1000_A+Y/vdu.lzS0Gq1l--
