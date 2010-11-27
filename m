From: Michael Monnerie <michael.monnerie@is.it-management.at>
Subject: Regression 2.6.36 - driver rtl8169 crashes kernel, triggered by user app
Date: Sat, 27 Nov 2010 21:22:22 +0100
Message-ID: <201011272122.28164@zmi.at>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart129095197.KUNcXHk1Mz";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailsrv1.zmi.at ([212.69.164.54]:60275 "EHLO mailsrv14.zmi.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753279Ab0K0UWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Nov 2010 15:22:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart129095197.KUNcXHk1Mz
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

This is the 3rd time I send this, and I did not get any answer.
I thought *regressions* are a bad thing that would be handled quickly?
Maybe this helps: *SHITTY DRIVER NOT WORKING ANYMORE*

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

--nextPart129095197.KUNcXHk1Mz
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.15 (GNU/Linux)

iEYEABECAAYFAkzxaIMACgkQzhSR9xwSCbQoJwCg2eTe6ZwKOOGh4hKe7HHVtppp
GcQAoJ4G4IZUK6hTFmeOAFrlPzulW0kP
=uaNU
-----END PGP SIGNATURE-----

--nextPart129095197.KUNcXHk1Mz--
