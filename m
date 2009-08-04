From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [Alacrityvm-devel] [PATCH v2] net: Add vbus_enet driver
Date: Tue, 04 Aug 2009 09:57:52 -0400
Message-ID: <4A783E60.7080203@gmail.com>
References: <20090803171801.17268.93846.stgit@dev.haskins.net>	<20090804010915.17855.2660.stgit@dev.haskins.net> <20090803.193836.248921133.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig436072B2FA6A57E28D19D323"
Cc: ghaskins@novell.com, netdev@vger.kernel.org, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754628AbZHDN55@vger.kernel.org>
In-Reply-To: <20090803.193836.248921133.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig436072B2FA6A57E28D19D323
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

David Miller wrote:
> From: Gregory Haskins <ghaskins@novell.com>
> Date: Mon, 03 Aug 2009 21:14:04 -0400
>=20
>> net: Add vbus_enet driver
>>
>> A virtualized 802.x network device based on the VBUS interface. It can=
 be
>> used with any hypervisor/kernel that supports the virtual-ethernet/vbu=
s
>> protocol.
>>
>> Signed-off-by: Gregory Haskins <ghaskins@novell.com>
>=20
> I'm fine with this, it depends upon the vbus infrastructure so
> whoever pulls that in can pull this in as well:
>=20
> Acked-by: David S. Miller <davem@davemloft.net>

Thanks, David.

If there are no other comments/objections, I would propose to pull this
into linux-next.  I have prepared a branch specifically for this
purpose, which can be found here:

git://git.kernel.org/pub/scm/linux/kernel/git/ghaskins/alacrityvm/linux-2=
=2E6.git
linux-next

I have also folded the following update to MAINTAINERS into the series:

diff --git a/MAINTAINERS b/MAINTAINERS
index d6befb2..7cbcf5d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2707,6 +2707,12 @@ L:       linux-mips@linux-mips.org
 S:     Maintained
 F:     drivers/serial/ioc3_serial.c

+IOQ LIBRARY
+M:     Gregory Haskins <ghaskins@novell.com>
+S:     Maintained
+F:     include/linux/ioq.h
+F:     lib/ioq.c
+
 IP MASQUERADING
 M:     Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>
 S:     Maintained
@@ -4555,6 +4561,12 @@ F:       drivers/serial/serial_lh7a40x.c
 F:     drivers/usb/gadget/lh7a40*
 F:     drivers/usb/host/ohci-lh7a40*

+SHM-SIGNAL LIBRARY
+M:     Gregory Haskins <ghaskins@novell.com>
+S:     Maintained
+F:     include/linux/shm_signal.h
+F:     lib/shm_signal.c
+
 SHPC HOTPLUG DRIVER
 M:     Kristen Carlson Accardi <kristen.c.accardi@intel.com>
 L:     linux-pci@vger.kernel.org
@@ -5423,6 +5435,19 @@ S:       Maintained
 F:     Documentation/fb/uvesafb.txt
 F:     drivers/video/uvesafb.*

+VBUS
+M:     Gregory Haskins <ghaskins@novell.com>
+S:     Maintained
+F:     include/linux/vbus*
+F:     drivers/vbus/*
+
+VBUS ETHERNET DRIVER
+M:     Gregory Haskins <ghaskins@novell.com>
+S:     Maintained
+W:     http://developer.novell.com/wiki/index.php/AlacrityVM
+F:     include/linux/venet.h
+F:     drivers/net/vbus-enet.c
+
 VFAT/FAT/MSDOS FILESYSTEM
 M:     OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
 S:     Maintained




--------------enig436072B2FA6A57E28D19D323
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkp4PmAACgkQP5K2CMvXmqFoIACdHaulCPWHEg+xBi4n9uMFk6RG
cTYAn1Bcf1JoHEYrc13nb23igw99tXZq
=hVV/
-----END PGP SIGNATURE-----

--------------enig436072B2FA6A57E28D19D323--
