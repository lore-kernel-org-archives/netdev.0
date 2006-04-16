From: Johannes Berg <johannes@sipsolutions.net>
Subject: softmac: semantics of SIOCSIWFREQ
Date: Sun, 16 Apr 2006 14:34:48 +0200
Message-ID: <1145190888.6560.22.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-8tUV8kdVb81qTv4NvdSU"
Cc: softmac-dev@vger.kernel.org, Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([213.151.39.204]:47529 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750724AbWDPMfQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Apr 2006 08:35:16 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-8tUV8kdVb81qTv4NvdSU
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

[breaking out to a new thread so discussion on this doesn't get too
hidden, CC Jean since he designed this]

> - Is SIOCSIWFREQ allowed while associated?

No idea.

> - If the flag IW_FREQ_FIXED is set, should all activitity
>   including scanning only be allowed on this frequency? (Actually
>   a better would even be to work with channel/frequency sets.
>   These sets would make a lot of sense for parallel scanning
>   whith more than one device.)

Yeah, but that's impossible to code on top of the current wext
structures I'd say.

> - Is there any use of the control, if the frequency is not fixed?

Good question :)

> SIOCSIWFREQ and SIOCGIWFREQ appear to be good candidates to be
> included in the softmac. If I would have a rough idea, what the
> semantics should be, I would even volunteer to implement it.

Yes, they definitely could/should be moved into softmac, but when
writing softmac I had no real incentive to do it because I didn't want
to dig up the info for all the above points :)

I was thinking of adding all the 'what is this ioctl supposed to do'
things we came up with to the softmac or netdev wiki. Would that be
good/useful, or should we just put it into that driver writers guide?

johannes

--=-8tUV8kdVb81qTv4NvdSU
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUAREI556Vg1VMiehFYAQIWDhAAtobvf7ToEJyCS+w7BUjmKRAIU9b/EZNd
TVTPo0z/oskGEfYl7etE2E6kqB7ks7GqgaeWhKyq0ims2UC8adyaGa61DXa3uKF5
lWUd0WnYMqSAADL20U7WRuHXzMsyeKkDmhybuiWYx0oemQY4h3nF/kzZjDZVzTOs
aVnnqbduyYa3y0xNSIc9ImrXpe6b+3BgSvvkZEmsHzoTZIJ/lVptveIq3rsz1W39
tecc7hc2IhyQ4UbEkubntWVbG9aLCuI/g3MXRzT7TUheaMNYXTE2kAq/JOjKtI5G
B3w6FTgBx1d3YxGkzxYftEJRiAOc8yIWwzNh1rk0EULUbEjfeZpg39jDgvpbqzRF
mHRvuqVR1cAvT/Nbb8y3wQ+EcD2KYCOd6ldUcKF+fyRC7Zav3eTxPnqb9aHb8Zwl
iuv2GfdS2Bwy3rOO0XGIenh5qgOr5JcEYGDjs/08wSSoXWH27oMq1zlrwdJcyoND
c8UatFqnAZLHMj+oCrsB4SUkjyGUWBZ0sCtekIr7W4X4TL3VatGSVVV0KiXkw43D
4mw1pYDu8x8/FDb+DMgZ0K471KrXvdbg0LhicGFOkA4mynzDXebQlJMuRT/UTXyE
MUBaOI/9dvYriJQ3XSV9+FUDgZiZdQAv87g1E7KQM2jT925dOt4Xto5wJ1MdayH5
zuKnEP0sO1g=
=0YCc
-----END PGP SIGNATURE-----

--=-8tUV8kdVb81qTv4NvdSU--

