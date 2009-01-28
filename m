From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: HCI crash after tearing down ppp connection
Date: Wed, 28 Jan 2009 10:53:32 +0100
Message-ID: <1233136412.4151.3.camel@johannes.local>
References: <1233082881.4455.14.camel@johannes.local>
	 <1233124538.18259.30.camel@violet>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-xsUP4ecx5WB6ljjsK7Oi"
Cc: netdev <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:44375 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514AbZA1JyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 04:54:10 -0500
In-Reply-To: <1233124538.18259.30.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xsUP4ecx5WB6ljjsK7Oi
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi Marcel,

> > I use /dev/rfcomm0 to connect to my cell phone, and then to the interne=
t
> > with ppp. Occasionally (two out of the three times I used it today)
> > after I poff the connection the machine locks up. The second time I got
> > a log, but because my display resolution is bad it mostly scrolled off,
> > so I only got to see that hci was involved somehow :/
> >=20
> > Anyone aware of any such issue? This is on
> > 2.6.29-rc2-wl-11979-gc32422d-dirty (-rc2 + wireless bits).
>=20
> I was assuming we fixed these, but we might ended with a new one since
> the TTY is changing a little bit and the Bluetooth TTYs are special
> since they are pure virtual TTYs. Can you reproduce this crash every
> time or is it happening only now and then?

Well, it's not happening every time, but fairly often.

> During the last weeks, I am chasing an USB issue with the USB anchors
> and how we use it. You might be hitting the one.

Yeah, I wish I could capture more information here. Can't seem to figure
out how to get more VT resolution. I'll try again. :/

johannes

--=-xsUP4ecx5WB6ljjsK7Oi
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJgCsZAAoJEKVg1VMiehFYjAsP/0y+ZrSENriKfVpQOJn5B/Dn
DZjv0zbw8Dv1ANuwiNETjqluP8qBt54j5qFAB9teZ4kuPPMiae0PRaoERjh930TI
VPbKS5m4QfXxctsDaeoa9ETolyGKEtBa9CRac7m5JPw1ZAIk+PFPYPH6BzjVVjl2
SVt8M8fcfcQrWyoIKtqfgbwGsyfD9ml660hz6D6hJcnKdih1ko1Jv43F4gtetMdL
jF8e78uSOEUWJx5pSqHRSZ7L/yWA2PPwSqhPPkDs1p4A0e6DGzquvYDLKd0ZeVFL
uhvWHPBxnDbCKtTX3izTJxRuEWPMq0x+14bF1FEnoS7e6kbqZ9+g0VzRqR4EDKAv
r34OeN2sLhZHhXx1fQbbBB0OmGY9lNpbZrPOAgZfHT6zDfYQUYRjhAS/lNKApwDi
w+uq8nugQvJjHmi9zT3XPzUvblyDAdSdF9V2/gOY1pnq+f/rW1Vb4jQH/Wx1IURW
77M+6tlHJzefy3p9ZTzcHg7N2Y50736NmzoEB392E8ua7c+Kzjxlov2WkwpyNqeM
JKhjq+4GxUsH3nV8LXptSNH/rMxvpHCtdbB7ZTRF7eyJ2CBrB9oXxoTWM/qs9joh
1wcppF66bwqlkT2pvTmNHAa4PMgsJC38gfY5fIJSg8ct9OyPWthKtHnJrKICLB9X
qCafvqHC9kdQaGGxDnLT
=DYP4
-----END PGP SIGNATURE-----

--=-xsUP4ecx5WB6ljjsK7Oi--

