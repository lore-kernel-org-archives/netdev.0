From: Paul Menzel <paulepanter@users.sourceforge.net>
Subject: r8169: Unconditionally disabling ASPM
Date: Sun, 15 May 2016 18:49:31 +0200
Message-ID: <1463330971.6071.35.camel@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-XVlwsNcC7EVNMou45FB4"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Realtek linux nic maintainers <nic_swsd@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gw90.de ([188.40.100.199]:43836 "EHLO mail.gw90.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750826AbcEORY1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 13:24:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XVlwsNcC7EVNMou45FB4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Dear Linux folks,


Running the Firmware Test Suite (fwts) [1] on an ASRock E350M1, it
suggests that ASPM should be enabled.

The module r8169 disables ASPM since the commit below.

commit ba04c7c93bbcb48ce880cf75b6e9dffcd79d4c7b
Author: Stanislaw Gruszka <sgruszka@redhat.com>
Date:=C2=A0=C2=A0=C2=A0Tue Feb 22 02:00:11 2011 +0000

=C2=A0=C2=A0=C2=A0=C2=A0r8169: disable ASPM
=C2=A0=C2=A0=C2=A0=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0For some time is known that ASPM is causing trouble=
s on r8169, i.e. make
=C2=A0=C2=A0=C2=A0=C2=A0device randomly stop working without any errors in =
dmesg.
=C2=A0=C2=A0=C2=A0=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0Currently Tomi Leppikangas reports that system with=
 r8169 device hangs
=C2=A0=C2=A0=C2=A0=C2=A0with MCE errors when ASPM is enabled:
=C2=A0=C2=A0=C2=A0=C2=A0https://bugzilla.redhat.com/show_bug.cgi?id=3D64286=
1#c4
=C2=A0=C2=A0=C2=A0=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0Lets disable ASPM for r8169 devices at all, to avoi=
d problems with
=C2=A0=C2=A0=C2=A0=C2=A0r8169 PCIe devices at least for some users.
=C2=A0=C2=A0=C2=A0=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0Reported-by: Tomi Leppikangas <tomi.leppikangas@gma=
il.com>
=C2=A0=C2=A0=C2=A0=C2=A0Cc: stable@kernel.org
=C2=A0=C2=A0=C2=A0=C2=A0Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.c=
om>
=C2=A0=C2=A0=C2=A0=C2=A0Signed-off-by: David S. Miller <davem@davemloft.net=
>

As over five years have passed now, do you think that is still needed?
I wonder why no module parameter was added back then, where users could
enable ASPM if it works on their systems? Because there is no such
situation and it always fails?


Thanks,

Paul


[1]=C2=A0https://wiki.ubuntu.com/FirmwareTestSuite
--=-XVlwsNcC7EVNMou45FB4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEABECAAYFAlc4qJsACgkQPX1aK2wOHVh+RQCeKu1NGY+Lx/fLAcoGY9gvexcp
SHMAnincx+89QiEG9FNJvPQEWHjwWgfP
=EMHq
-----END PGP SIGNATURE-----

--=-XVlwsNcC7EVNMou45FB4--
