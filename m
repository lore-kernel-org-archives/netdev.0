From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net tree
Date: Mon, 1 Mar 2010 16:47:21 +1100
Message-ID: <20100301164721.f8ce9fac.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__1_Mar_2010_16_47_21_+1100_2RYTlIYccz0aAOMh"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__1_Mar_2010_16_47_21_+1100_2RYTlIYccz0aAOMh
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

After merging the net tree, today's linux-next build (x86_64 allmodconfig)
produced this warning:

net/bluetooth/hci_sysfs.c: In function 'inquiry_cache_read':
net/bluetooth/hci_sysfs.c:441: warning: the frame size of 4208 bytes is lar=
ger than 2048 bytes

Introduced by commit ca325f698996c1a0770a67f41e7dc97a007d8bc2
("Bluetooth: Convert inquiry cache to use debugfs instead of sysfs")
which introduces a function with a 4096 char array on the stack.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__1_Mar_2010_16_47_21_+1100_2RYTlIYccz0aAOMh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkuLVOkACgkQjjKRsyhoI8zrfgCfVfKWnHwTrmLvbZo5anCEyVuJ
HW4An0IRiICeQ0ciB4LkOqlWixUEqe9I
=fNPV
-----END PGP SIGNATURE-----

--Signature=_Mon__1_Mar_2010_16_47_21_+1100_2RYTlIYccz0aAOMh--
