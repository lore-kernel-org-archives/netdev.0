From: Michael Monnerie <michael.monnerie@is.it-management.at>
Subject: Regression 2.6.36 - driver rtl8169 crashes kernel, triggered by user app
Date: Thu, 18 Nov 2010 15:49:07 +0100
Message-ID: <201011181549.08545@zmi.at>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1324460.k5j5z1qcUa";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1324460.k5j5z1qcUa
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

I did not get any answer, so here again:

Dear list, I've hunted down a bug which does *NOT* occur in kernel=20
2.6.34.7-0.5-desktop from openSUSE 11.3, but crashes stock kernel 2.6.36=20
triggered by a user!

It's actually very simple. From my desktop (kernel 2.6.36) I "cd" to an=20
NFS4 share, where a xz compressed image of Win7-64.iso.xz is located.

# cd /q/iso-images

and then I try to uncompress it there (as user, not root!):

# xz -kv Win7-64.iso.xz

With kernel 2.6.34.7-0.5-desktop, this runs with ~41MiB/s without=20
problems.

With kernel 2.6.36, it runs at ~26MiB/s, and while doing so, dmesg shows=20
a lot of noise about r8169 complaining:
http://zmi.at/x/kernel2.6.36-crash86.jpg

Here are 2 pictures of different crashes:
http://zmi.at/x/kernel2.6.36-crash84.jpg
http://zmi.at/x/kernel2.6.36-crash85.jpg

Neither the dmesg-messages nor the crash happens with kernel=20
2.6.34.7-0.5-desktop as delivered by openSUSE 11.3, but it always fully=20
crashes 2.6.36. I've retried about 10 times, it *never* finished to=20
uncompress the ~3GB image. At around 500-1000MB the kernel was gone.

I'm sure someone knows how to fix it. :-)

=2D-=20
mit freundlichen Gr=C3=BCssen,
Michael Monnerie, Ing. BSc

it-management Internet Services
http://proteger.at [gesprochen: Prot-e-schee]
Tel: 0660 / 415 65 31

****** Radiointerview zum Thema Spam ******
http://www.it-podcast.at/archiv.html#podcast-100716

// Wir haben im Moment zwei H=C3=A4user zu verkaufen:
// http://zmi.at/langegg/
// http://zmi.at/haus2009/

--nextPart1324460.k5j5z1qcUa
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.15 (GNU/Linux)

iEYEABECAAYFAkzlPOQACgkQzhSR9xwSCbSqTwCgj/IHD4/1uBubbJhlAZ6BOXUZ
vW4AnRhFzEcz0WetzXxRzq8YGyXaa/NC
=o2+a
-----END PGP SIGNATURE-----

--nextPart1324460.k5j5z1qcUa--
