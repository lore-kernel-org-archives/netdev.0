From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: sky2 fails when memory exceeds 2GB on amd64 kernel
Date: Sun, 21 Feb 2010 02:06:06 +0000
Message-ID: <1266717966.24602.14.camel@localhost>
References: <4B7F52E0.2010303@texasbb.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-b7RIpgbq/kyjnBTDvKrP"
Cc: 570268@bugs.debian.org, Dale Schroeder <dale@texasbb.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43291 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755719Ab0BUCGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Feb 2010 21:06:22 -0500
In-Reply-To: <4B7F52E0.2010303@texasbb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-b7RIpgbq/kyjnBTDvKrP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Stephen,

Debian received this bug report on sky2:

Dale Schroeder wrote:
> No matter what brand, size, or speed of ddr2 RAM I try, I cannot=20
> successfully boot when the installed memory is greater than 2GB.
> The system is an Acer Aspire M1100 with the most recent BIOS.  I have=20
> tried with kernels 2.6.32-5 and 2.6.30-8squeeze1.
>=20
> During the boot sequence, sky2 fails with a 0x2010 pci error; then=20
> several programs slowly load until dmsg appears, at which time the=20
> screen fills with hexadecimal errors similar to those in this debian bug=20
> thread:
>=20
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D457967
>=20
> Disabling the network interface in the BIOS allows bootup to finish,=20
> although some programs fail to load due to the missing network connection=
.
> Decreasing the RAM to 2GB returns booting to normal.
>=20
> I've seen numerous references to bugs with this network hardware and the=20
> amd64 kernel, but none related to adding extra memory.  I am unaware as=20
> to how I can capture the errors, since I cannot finish the boot process=20
> when the errors happen.

Further information:

> I tested another network card, a Netgear GA311 which uses the r8169 drive=
r.
> With this card, all 4GB of memory is recognized and the system=20
> successfully boots.
> This would seem to rule out the BIOS and points to sky2 on the Marvell=20
> m/b chip
> being my problem.
>=20
> Obviously, the new card doesn't resolve the bug, but it does solve my=20
> problem.

Does this sound like a plausible symptom of the bugs fixed by:

f6815077e75c5b7f55b56fc3788e328514d4e72a sky2: fix transmit DMA map leakage
3fbd9187d004149fb8a98c9cb51ef9f4a4f66aca sky2: hand receive DMA mapping fai=
lures

In any case, are the above suitable for 2.6.32-stable (once merged by
Linus)?

Ben.

--=20
Ben Hutchings
73.46% of all statistics are made up.

--=-b7RIpgbq/kyjnBTDvKrP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS4CVCOe/yOyVhhEJAQKrww//Yd9Ye8fHdK2oiNBLm+HW0GZDIMQD/Gol
UnkE7af8cIVByF63lAibP3DcQgfN5c25bUpNCpZJDPQe8935urqRpH+4UL5MmTw+
63Qr9Ap1SPTEeHAbXBqyqKT8g7aLc+tspGkU9mMZ9GrTeXOqA/tViKyekM2mD5wj
S8OXG5XLB4Kj0Jn7aCwlnQsTAQS4+5OoreJhFHXfJQTfGgRfGZ9udpvxVJyKymqV
myHqKNIDStYmGTuCc73QwdYbB0N8Nu+PACfISObLim0XtZG/Hl+4t+WztIJDv0eX
8i3zHSsd30uqQsMJKuzmf0ttbiAEdSYouODvsnBmi2/5I6brtxOYfdvYuNFGaPY9
TXUGcWMVqpZ1Yzv5xz3clCCtLIFlYpUO7lmi/FBsGzeKBEqasuAZ0ik9rfY1kMc3
iD33L+uQsUUKHm7DKsoSbwmFWs01wflPkIvAw+t26AFsPJKaeeTZwn7cZXhvsGku
BVSzv418JZQCDy+cjpJmWYtOLt2+vBA1BAD0wefLTFgd9/KrurVXVORUVaGjVQgn
L9XzgsidOs8D5teh4SM+0k4PjaQMpZaHIZpG1E2BU5jVFJ9dH4kWdVsN66Fc/edm
mSpk5Au+FaLw7AnS7zmrxBFsZxZ+/lOnLfCdUomQpm9ouJjVr9tQWiuESWtWieAQ
a4dv4uI+3Tc=
=SiQI
-----END PGP SIGNATURE-----

--=-b7RIpgbq/kyjnBTDvKrP--
