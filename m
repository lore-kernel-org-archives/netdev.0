From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] printk: Let %pR handle NULL pointers
Date: Sun, 04 Jan 2009 10:31:26 +0100
Message-ID: <1231061486.3313.5.camel@johannes>
References: <1230979341-23029-1-git-send-email-xyzzy@speakeasy.org>
	 <alpine.LFD.2.00.0901030905140.3179@localhost.localdomain>
	 <1231019614.15389.104.camel@pasglop>
	 <Pine.LNX.4.58.0901031827380.25853@shell2.speakeasy.net>
	 <25339.1231046074@turing-police.cc.vt.edu>
	 (sfid-20090104_061506_353829_E8D12250)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-+22ClqJgGoN6VBNiBDrI"
Cc: Trent Piepho <xyzzy@speakeasy.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Harvey Harrison <harvey.harrison@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:60725 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980AbZADJbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 04:31:41 -0500
In-Reply-To: <25339.1231046074@turing-police.cc.vt.edu> (sfid-20090104_061506_353829_E8D12250)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+22ClqJgGoN6VBNiBDrI
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2009-01-04 at 00:14 -0500, Valdis.Kletnieks@vt.edu wrote:
> On Sat, 03 Jan 2009 21:02:15 PST, Trent Piepho said:
> > resource pointer.  Maybe "[]" or "[-]" would be better?  A null MAC add=
ress
> > could be ":::::" or "x:x:x:x:x:x".  "N.U.L.L" or "x.x.x.x" for a null I=
P4
> > address.  And so on.  So the printout looks nicer when a NULL pointer i=
sn't
> > a bug.
>=20
> Have to be careful for IPv6 addresses - '::' is a legal representation of
> an all-zeros address.  Also, N.U.L.L. may give indigestion to logfile par=
sers
> that are expecting a numeric value in the IP address.  It's however uncle=
ar
> whether we should pick something that doesn't have 3 periods in it, so it
> can't match, or whether *that* will give regexp-based logfile readers
> indigestion when they don't pick up an IP address where they expected...
>=20
> Do we want the %pI6 format to do the multiple-zeros -> :: compression?

Eh, why ever care? We aren't passing NULL pointers in, hopefully, or the
code was crashing, at least before the conversion... So as long as we're
careful adding new users, I don't see a problem with not handling NULL.

FWIW, I'd think for MAC addresses there are multiple possible
interpretations, some wireless code assumes broadcast for NULL, and I'm
sure there are others like all-zeroes.

johannes

--=-+22ClqJgGoN6VBNiBDrI
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJYIHsAAoJEKVg1VMiehFYNokQALdorQ7+klQZHotS+K8LlvNb
nMrb/x+YyGwoVGxbkFa3JrbmxS0fOOWnd5q2lDEz0QEO33BOWWstHmxyg13pcKJf
T0/gyZ5wHxPraqUf8i1TgbVZi2gqZXbRAlXNG/vF2B4zY7aiX3k1a7YzGVGFvd06
umLK1b1soKthpY9jIna5aGOqrasiZ4f4cguAQ1QUtrkk4XsfdVuy1esESX9J8hod
Ej1KXyXSeJujRBhI0QkNsZGLnftJIMdN5KoE9I+jJ1wgl3xO+iaXi+HygK/tTKtc
+saMWVnssJ/FagYjh+I9oCayAHYQru+x/tfkwD6Wx10u+kBm5berUo3TbZPbWuv2
8b/qISoRtaboiRiCXJ8zV/u5mSS3eGC9Tg+q4pmqIACcXtM/43io3Wq5bnsDmm5g
bdmPmFRX328G/2yooSZsC7h0p8Y2ournLRBTm+dQYfakdCLCehf0Ljx4J2pYtqRb
7N/mH40oCl0T39dLoJzzuaVRnL0NDMhAjxVSQ0MJHiJK4c7HqSGvcvKPVGV7Ga8n
VBuxak6CSPXNVp2Hca4wK1eu1SAqErFETvFP2u5NmTWTM5NSMxpw1n4gb649c0IJ
zd1eUFLzWVuBd9+TzPA7++Am6J+DC5XnnBvVnydASSdRawOqVvfsa87peIFRV933
wDMB8P9vBSMzyapOwTVF
=FUwv
-----END PGP SIGNATURE-----

--=-+22ClqJgGoN6VBNiBDrI--

