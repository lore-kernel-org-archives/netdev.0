From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Wed, 27 Apr 2011 19:53:59 +0200
Message-ID: <32030A20-D4FE-4D44-9DBF-464E42F11B90@comsys.rwth-aachen.de>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
 <BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com>
 <BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com>
 <201104271157.49386.carsten@wolffcarsten.de>
 <BANLkTimNC9DgWtkTTtjC_v0FsxzvBMsQGw@mail.gmail.com>
 <BANLkTi=i5ZftuL++ORuy=n_yM_futWYoZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg=pgp-sha1; boundary=Apple-Mail-1--797874513
Content-Transfer-Encoding: 7bit
Cc: Dominik Kaspar <dokaspar.ietf@gmail.com>,
	Carsten Wolff <carsten@wolffcarsten.de>,
	John Heffner <johnwheffner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Lennart Schulte <Lennart.Schulte@comsys.rwth-aachen.de>,
	Arnd Hannemann <arnd@arndnet.de>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:43570 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754260Ab1D0SYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 14:24:04 -0400
Received: from ironport-out-2.rz.rwth-aachen.de ([134.130.5.41])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0LKB00E9TOE1RAG0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Wed, 27 Apr 2011 19:54:01 +0200 (CEST)
Received: from [192.168.4.14] ([unknown] [77.109.115.94])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0LKB005HMOE0PJ80@relay-auth-2.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Wed, 27 Apr 2011 19:54:01 +0200 (CEST)
In-reply-to: <BANLkTi=i5ZftuL++ORuy=n_yM_futWYoZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-1--797874513
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=us-ascii

Hi,

Am 27.04.2011 um 19:39 schrieb Yuchung Cheng:

> Hi Dominik,
>=20
> On Wed, Apr 27, 2011 at 9:22 AM, Dominik Kaspar =
<dokaspar.ietf@gmail.com> wrote:
>>=20
>> Hi Carsten,
>>=20
>> Thanks for your feedback. I made some new tests with the same setup =
of
>> packet-based forwarding over two emulated paths (600 KB/s, 10 ms) +
>> (400 KB/s, 100 ms). In the first experiments, which showed a =
step-wise
>> adaptation to reordering, SACK, DSACK, and Timestamps were all
>> enabled. In the experiments, I individually disabled these three
>> mechanisms and saw the following:
>>=20
>> - Disabling timestamps causes TCP to never adjust to reordering at =
all.
>> - Disabling SACK allows TCP to adapt very rapidly ("perfect" =
aggregation!).
>=20
> Did you enable tcp_fack when sack is enabled? this may make a (big)
> difference. FACK assumes little network reordering and mark packet
> losses more aggressively.

It's not necessary to do it manually. Linux will disable FACK as soon as =
it
will detected reordering

Alex

//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22222
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//


--Apple-Mail-1--797874513
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.17 (Darwin)
Comment: GPGTools - http://gpgtools.org

iEYEARECAAYFAk24WDgACgkQdyiq39b9uS6VogCggS1Vfw0jT5JAxo90Nxvvl7Xc
SAkAoIUQSXkFi7xGx20urzmrmZVAKdxY
=HZk1
-----END PGP SIGNATURE-----

--Apple-Mail-1--797874513--
