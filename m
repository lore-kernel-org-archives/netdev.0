From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Question about the drivers movement (IBM_NEW_EMAC)
Date: Fri, 12 Aug 2011 12:07:44 +1000
Message-ID: <20110812120744.1912ca01ab4e76faaa93892c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__12_Aug_2011_12_07_44_+1000_tfZtuX=5cQYvbMF5"
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__12_Aug_2011_12_07_44_+1000_tfZtuX=5cQYvbMF5
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jeff,

In commit 9aa328359545 ("ehea/ibm*: Move the IBM drivers") from Dave's
net tree, you not only move the drivers around, but you change
CONFIG_IBM_NEW_EMAC to CONFIG_IBM_EMAC.  Won't that mean that all the
PowerPC configs that currently set CONFIG_IBM_NEW_EMAC to y will no
longer build this driver?

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__12_Aug_2011_12_07_44_+1000_tfZtuX=5cQYvbMF5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJORIrwAAoJEDMEi1NhKgbsvA8H/0flvKjFD2UX1SIeWH/PHvrN
2ocpM3EzMiMuBAaEcACvzudQw0NMpem8XfcMTEMux/K4msp6YTLDjTwiNaP7oQvw
3n81QsHuqzp7Gfg+YuD/0Ru3/M1rQKFe2CFrTL6iumlUU8LstsIp4B/n/5glIF9W
sHQEVmsL8sjYkxgDNU+FmWfMte4pajE+i20dm32MzvjGCX7Ze3b57sejUMI6nC6w
Xx8ZQr1EZFPwZFNxgbwB589o94vAz8nHyg+g5AznLL6peaZQYhXwFZ0XBWuw5OyO
t8VUtV8xE/7a853u6ExYRgAwZTkl0XnG8oUQND7He2OCcJ1aIo3bqz74zp+whpo=
=Wprq
-----END PGP SIGNATURE-----

--Signature=_Fri__12_Aug_2011_12_07_44_+1000_tfZtuX=5cQYvbMF5--
