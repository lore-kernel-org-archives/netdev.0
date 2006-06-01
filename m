From: Johannes Berg <johannes@sipsolutions.net>
Subject: monitor_during_oper on rt*pci (or any other pcmcia card)?
Date: Thu, 01 Jun 2006 13:47:29 +0200
Message-ID: <1149162449.8877.72.camel@johannes>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-QqxWCSBnsL1FPu+domAr"
Cc: Ivo van Doorn <ivdoorn@gmail.com>,
	rt2x00-devel@lfcorreia.dyndns.org, Jean Tourrilhes <jt@hpl.hp.com>,
	Florian.Rampp@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:4786 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750720AbWFANFw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 09:05:52 -0400
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-QqxWCSBnsL1FPu+domAr
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hey,

Florian approached me with a project where you need a pcmcia card that
can have monitor_during_oper. I'd use bcm43xx but unfortunately the
signal strength calculations are way off right now, and that's another
requirement.

Can the rt family of cards be made to support this with reliable signal
strength readings?

Or maybe I should rephrase the questions: which pcmcia cards can support
this in their hardware? I might be willing to port their drivers over to
d80211 just to get some more familiarity with the stack...

Now, if no one can point me to ones that do have working signal
strength, I'll probably have to do more reverse engineering on bcm43xx
to get some reliable readings :/

Thanks,
johannes

--=-QqxWCSBnsL1FPu+domAr
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARH7Tz6Vg1VMiehFYAQIPBQ//X7/r9nMAxmsP4wi3BaK01DCrnPWYYkbq
pyQIc3PbnHHca7pr1YuchOvJH8ySckvSWkQsO8DQXMEtB3hVIKsnyGIsG6yhR+bl
qDavW9efLswFmj+CElHP1quHEaPb5wy38VVLPE/HQDAAOSH1NhZUW/4KhESIUOcM
KMgu/65/6sS8T3Bak1jFoLZlnWZmw2lOfe7RiQDVCKhBCm/3P7lmrpCn6eBozk4Z
lnXG8/43RCO3yRmkfNILWaIOFaeHAWkX2Kw8romBlSOMsT5GrOcbHQajBd9Cf18X
GRCsGER4vIkdWrcWRXEhZfRCqB0G1+6vyj5rzQVPKhbc/ivE3D25Zlp7Y3F6z97y
YFEX2K6a4rnamghLNFlBBVLRvI8Ds6lbFPie9ya8/crW71IjXLpTzKB9ctMr1GGd
Wfg/1aKOVmDW1X0NpBMaJOw6OqhBRfl85LzPImSkeWajDj/kIqsfyysr6dVueH6s
J+qGAUCNHJo9gUKJ3J8iZ+kznsxkNwAlYIItrEtD8F0tfJeZsUM3v7ThwQwBwFcF
IW9cxnP15y3I7x9YrIhBSpabftSySxymMhBTtwWgbDxXaUD6Gjui/OUI+4mvJyEG
bHwe+OzE6G4dVoCLwyEzVXDZkW1O3IjhuJiynliJ+pNuUqNxhJ2xuSB2skMG1No3
2OS+iKhc7M8=
=pWJS
-----END PGP SIGNATURE-----

--=-QqxWCSBnsL1FPu+domAr--

