From: Johannes Berg <johannes@sipsolutions.net>
Subject: a short look at d80211
Date: Tue, 16 May 2006 21:34:38 +0200
Message-ID: <1147808078.10137.13.camel@johannes>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-7dHy5K7x8cVACfldqUMj"
Cc: Jouni Malinen <jkm@devicescape.com>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:20138 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932210AbWEQMFt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 May 2006 08:05:49 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-7dHy5K7x8cVACfldqUMj
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

I finally decided to familiarise myself with d80211 a bit more :)

Here are some questions on the code again.

MICHAEL_MIC_HWACCEL seems to be always defined, what is it used for?

IEEE80211_LEDS should probably go away, in fact it should be fairly easy
to register a led trigger driver for each kind of LED and each device.
Then drivers can register a led driver, even with a default led
source... :)

Could ieee80211_msg_* be upper-cased so it's clear right away those are
constants?

Why does IF_TYPE_VLAN exist if according to the comment it isn't used?

bcm43xx doesn't do hardware tsf synchronisation, it provides on each
frame the lower 16 bits of the tsf at the time the frame was received
(no, I don't know if it's at the first bit of the plcp or whatever).
Hence, it'll need to do tsf updates in software whenever necessary.
Could d80211 provide some support for this? Or asking the other way
around, how should it do that?

There's more, especially related to bcm43xx and power saving, but we're
only just beginning to understand how that might work.

johannes

--=-7dHy5K7x8cVACfldqUMj
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARGopTKVg1VMiehFYAQIjxA/+IKCfv2hzGAjslOqdaCVdhu8yT0n49bD6
alWyiM4OewUfR9jX0zyxPcs6E4d4wwLfY2FrgM+rKdv0Iq1oIi2QvQiyD9aSd1nQ
IbNCC+iZlYb3WGWTOfbJAmMulDBTn5xHvIjdjtOqo14NwvFNmMLRNjgVbq4J2Bzx
FTWKrlOHIl7NUP1FgXyXfuKY51dsqrme8kQ/5v9eary/CqO5I37OC3jayayLkGeX
lq6+YID3iiQqkpCzSPqX70U4YkQjehHmOUxOgAD/+LUxfvQsyWo39sJx8I5ov4RW
iB7CX3dIVr/Wzw8BIoZBo/b3SZqECA/IR/tEcbOIZQMoUgoWAu0Y1IMAowpTMQE2
/5Y4rdOUu9j3B7lpo1ntWiFeUrsP+FpuY23dSoqNcIuD1f75CXdaC1Fuj+X4KYr6
7M56ryvUiPx6z35AedTMiW36ElV574IqzzkkTQEMpTfUVQ4zxX15CllirTENTEfs
3NxXHdgZIwjLkkmSZWy1lvb6WjS0yl5N6nRerSw+D/hJ0eWgCsw8FRMI8Mg7ze8e
7dEyNyLVuVW3E+dD4IUvN97gNeMaMnJTQL/7aiME/GC5Y5MctkCd40EFbR8b65Mj
XrlURT8DvOz0scJTl0UjQbCwq9ncQQqWN/1bVCyyWzXkEsmzgTSfUU/g/dh/2bR+
J6oeIuZ4WAA=
=jlL1
-----END PGP SIGNATURE-----

--=-7dHy5K7x8cVACfldqUMj--

