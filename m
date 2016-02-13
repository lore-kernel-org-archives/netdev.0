From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] af_unix: Don't set err in unix_stream_read_generic
 unless there was an error
Date: Sat, 13 Feb 2016 00:18:49 +0000
Message-ID: <1455322729.2801.71.camel@decadent.org.uk>
References: <56B4EF04.2060407@canonical.com>
	 <87zivebxjr.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-RpDbW5AZgxGOlY6is3SL"
Cc: hannes@stressinduktion.org, edumazet@google.com,
	dhowells@redhat.com, ying.xue@windriver.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Joseph Salisbury <joseph.salisbury@canonical.com>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <87zivebxjr.fsf@doppelsaurus.mobileactivedefense.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-RpDbW5AZgxGOlY6is3SL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-02-05 at 22:30 +0000, Rainer Weikusat wrote:
> The present unix_stream_read_generic contains various code sequences of
> the form
>=20
> err =3D -EDISASTER;
> if ()
> 	goto out;
[...]

I wish people would stop writing code like this. =C2=A0At one time it may
have been a useful micro-optimisation, avoiding an extra branch in the
successful case, but gcc now appears to do that itself. =C2=A0So it makes
the code less clear and runs the risk of introducing this sort of bug,
for no obvious benefit.

Ben.

--=20
Ben Hutchings
Sturgeon's Law: Ninety percent of everything is crap.
--=-RpDbW5AZgxGOlY6is3SL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVr52aee/yOyVhhEJAQrlPRAAib7GvkTeP2kfgOz3+Mx0G2x0pLjLIVAd
W8Lkwr3Y8gqYviXJOPiBK9Cse+8TtI0SMh4rzgc2ij1ybv1cWTq+S+mX2zFZCQse
WOJDFtLYKJbhjTYk1L1aZbehb3kcMIEQNkoRkwYu35sx6bm1ZEjBGCCpN7RpdZ//
hae1mtpYqRJbEeJLlcuE8x0IW+6Q4SAUwF/4lNAdd4rBUIzAsEuHRRRiXlIIEo/6
O6CtUP3fdolBhHSfbdrlN2JmjSSc8Ul9++zSaTI1lixBWEcdQWBjEgTrnjbZhZCs
Iw8wqnM7H/8PJyHMAO6DaEquwTlkBp4zHso6kJX7ojX+sPutS3V9LChIFXkEJYSi
dM2XgvtF+4mSrAY0/8bQkUGG0iH6pVrNU3tgZXZvhlJxDeMuvxfsGzGn3IBNvADh
zKKPuTjFDb15qF7O/KbeGb60p52YiR+nMWIu/BITAnyy/2UMeqty1LgvWa46XtE1
gcUQOsBUXfk55MfbFGRCnyvRWQr9dWcbe1rru7O1iP8trny4kXG9NJTfcfhCe+zV
Tz3TgZK7eea0zQTh/gqawi/N8GXRRj4hN28C6Cx2qFzETHYmjUeeWQM3571K4jgY
8ohFN2SeM/gWeJYuMsYIy+fVkgAKZJAnNfczKUb/QJ9clhDx45QJJuvdVXbSBHu2
5jftT1IW6QE=
=fS2a
-----END PGP SIGNATURE-----

--=-RpDbW5AZgxGOlY6is3SL--
