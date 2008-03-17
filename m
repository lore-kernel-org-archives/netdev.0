From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [2.6.25-rc5-mm1] regression: cannot run Postfix sendmail command
 as non-root
Date: Mon, 17 Mar 2008 14:06:15 +0100
Message-ID: <47DE6CC7.2000405@imap.cc>
References: <20080311011434.ad8c8d7d.akpm@linux-foundation.org> <47D98510.60801@imap.cc> <47D9A8DF.30809@fr.ibm.com> <47D9C1F0.6050803@imap.cc> <47DE4B7B.9040504@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig7B6DABE6C137B0E4DCEACF24"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from posthamster.phnxsoft.com ([195.227.45.4]:4630 "EHLO
	posthamster.phnxsoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752181AbYCQNH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 09:07:26 -0400
In-Reply-To: <47DE4B7B.9040504@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7B6DABE6C137B0E4DCEACF24
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Daniel Lezcano schrieb:

> I was not able to reproduce it, but I think I didn't configured postfix=
=20
> as I should had. What version do you use ?

It's the one that comes with openSUSE 10.3:

ts@xenon:~> rpm -q postfix
postfix-2.4.5-20.2

> If I may ask you, can you put your postfix configuration file and a=20
> strace -f of your failing command ? on your website, that will help me =
a=20
> lot to investigate.

Sure, no problem. You may find them at

http://gollum.phnxsoft.com/~ts/linux/main.cf
http://gollum.phnxsoft.com/~ts/linux/strace.log

HTH
T.

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig7B6DABE6C137B0E4DCEACF24
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFH3mzHQ3+did9BuFsRAnbKAJ9oHGy2VxrAEhzAE/fix4Fhx0dq4ACbB0tu
5L7z+g04FX9uxXKRm/5E0wI=
=vk8G
-----END PGP SIGNATURE-----

--------------enig7B6DABE6C137B0E4DCEACF24--
