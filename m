From: Ben Hutchings <ben@decadent.org.uk>
Subject: Net driver module dependencies on PHY driver modules
Date: Sat, 31 Oct 2009 11:42:06 +0000
Message-ID: <1256989326.3136.284.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-c3kygRIsDqPxOfZuG5ea"
Cc: 553024@bugs.debian.org
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37191 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757504AbZJaLmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Oct 2009 07:42:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-c3kygRIsDqPxOfZuG5ea
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I'm handling a bug report <http://bugs.debian.org/553024> relating to
tg3 using phylib and missing the broadcom module.

There seem to be two general problems here:
1. PHY drivers are not auto-loaded
2. An initramfs builder cannot statically determine that a net device
requires a PHY driver

It seems to me that PHY drivers should have aliases based on MDIO PHY
ids, and phylib should request_module() if no suitable driver is
registered.  This would solve (1) and go some way to solving (2).

Ben.

--=20
Ben Hutchings
The generation of random numbers is too important to be left to chance.
                                                            - Robert Coveyo=
u

--=-c3kygRIsDqPxOfZuG5ea
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASuwiiee/yOyVhhEJAQKnzxAAoUldKuRBD2D5sRuMYBQxzFUPwj+YImJh
xamGdkApn3z7Siyv4EXVAdeVgm0Dl0lOyPCamM+tdlxDpiCzNl5QwpnjCGvx2WNi
MycJn53D8VE47ITxRxeoohctcHt3t8UljbvcBH9H0kTVQU3vt8oQUMzprqcOH2dN
c7My8/k3SiUd4ODBkg44N6e7qfmFhxzAPbz/hTxtdwtmIRXM3KV26BIPpRzb8/HA
QSvUoWa8mk/TTfGhy+TvC6W/l5+hPvBVyCHhCZ65yF8RQDxiOHzmrx5/pE03wPoh
0sNra0brN/k5Ium7lA+06R2OB6yQk1zwl34aMle5M98hY2wS8c4uwjSQxL6Ev6iZ
cdta62SCzc8WHWYGRWm2yijY3IgNDAGkWxCv1jHAt+4Kmz1Y5j9DCVLuYeaMcgY/
uZW5qEOXa1/mSdZP3Eb7aB888fH7kA7JdVutWvXSlpDg0Hja7ea9RizItPYCLyfs
FhcT0HKDXr+sV5+fEd4vxH6FyT+ekcFJjmI0ezi6zx/Qrhb3ivK/0SFDExyMPAO6
rUlYtXprsbVFqyQInc+HOeGTPp2VIv8DaWAMC8E97xC9m+ghQIyQoMbwDIEtN1wy
NFZ+pv1UyuM7KFaS2kZp1Hav5dq8T+lcJCxMc1bJS4r0jG4PyFmZ3j+cMD/IZgKH
ICa7zilVG+k=
=PLtU
-----END PGP SIGNATURE-----

--=-c3kygRIsDqPxOfZuG5ea--
