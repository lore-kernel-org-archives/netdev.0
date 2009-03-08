From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 1/2] gigaset: return -ENOSYS for unimplemented functions
Date: Sun, 08 Mar 2009 01:55:06 +0100
Message-ID: <49B3176A.7000004@imap.cc>
References: <20090307-patch-00.tilman@imap.cc>	<20090307-patch-01.tilman@imap.cc>	<20090307142609.2995bb3d@infradead.org>	<49B30FC4.5040305@imap.cc> <20090307163522.1165494b@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1BCE8383244CF301D995FF9D"
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Paul Bolle <pebolle@tiscali.nl>,
	Hansjoerg Lipp <hjlipp@web.de>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:55699 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751544AbZCHAzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 19:55:20 -0500
In-Reply-To: <20090307163522.1165494b@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1BCE8383244CF301D995FF9D
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 08.03.2009 01:35 schrieb Arjan van de Ven:
> On Sun, 08 Mar 2009 01:22:28 +0100
> Tilman Schmidt <tilman@imap.cc> wrote:
>=20
>> Am 07.03.2009 23:26 schrieb Arjan van de Ven:
[...]
>>> ENODEV is what would be more appropriate.
>> Not at all. ENODEV means "no such device", which would be quite wrong.=

>> The device does exist and is in all probability working perfectly
>> fine. It just doesn't implement that particular ioctl.
>=20
> then -ENOTTY is the right answer

Interesting, though slightly surprising proposition.
"Not a typewriter" is certainly correct. :-)

"Not a tty device", however, which I take is the customary
interpretation, much less clearly so. The device most certainly
is a tty device. It just happens to know a few additional ioctl
commands which may or may not be implemented, depending on the
kernel config.

Not to question your authority, but I would really like a second
opinion on that issue before I adopt your proposition, simply to
minimize the risk of getting another objection from someone else
who feels that ENOTTY is inappropriate in that situation.

Thanks,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig1BCE8383244CF301D995FF9D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFJsxdzQ3+did9BuFsRArTVAJ9khgOCxeAH35LYWYIXiLgPHFk4rACghkd5
V9Hor1hIHHOpjr89yda1AZA=
=h1EP
-----END PGP SIGNATURE-----

--------------enig1BCE8383244CF301D995FF9D--
