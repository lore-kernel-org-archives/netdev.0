From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] ssb: mark ssb_bus_register as __maybe_unused
Date: Tue, 3 Nov 2015 17:27:21 +0100
Message-ID: <20151103172721.04533081@wiggum>
References: <5928552.0ccybX7Zly@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/Ljre1AhLXzX0AwMXVYgLnsm"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	linux-kernel@vger.kernel.org, zajec5@gmail.com,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5928552.0ccybX7Zly@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/Ljre1AhLXzX0AwMXVYgLnsm
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 03 Nov 2015 16:05:51 +0100
Arnd Bergmann <arnd@arndb.de> wrote:

> The SoC variant of the ssb code is now optional like the other
> ones, which means we can build the framwork without any
> front-end, but that results in a warning:
>=20
> drivers/ssb/main.c:616:12: warning: 'ssb_bus_register' defined but not us=
ed [-Wunused-function]
>=20
> This annotates the ssb_bus_register function as __maybe_unused to
> shut up the warning. A configuration like this will not work on
> any hardware of course, but we still want this to silently build
> without warnings if the configuration is allowed in the first
> place.


Is there a simple way to disallow this configuration?

--=20
Michael

--Sig_/Ljre1AhLXzX0AwMXVYgLnsm
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWOOBpAAoJEPUyvh2QjYsOJVQQANoNgd/6iKajpJCa7KNw6v6Z
DKvX36L5ZQND2d2iSG0c24GTIVprRq2R19+v5tMAY97JvXGXRdjMZLQAc6rxIwLn
ZeMO4omQLpHSZuWXq+Y6/q7XoojNo+0wvyYzlOq3KaAs0mzDhjhwF0gisJOzvjhM
LZ0VjgHcPCQeJZmNIAvlzwA4iW5k1iEZwMZ2boXTYjVBwto9MkPwXEPXSgrPt+oo
Bw+nsH2/O+P57kVZanji7mP8ZYqYLVchpi0UOmRxZtOK5dcxZa67U8zcI+ssZqz/
qNdi5tCh+nMH+p+zlakSHzhIMYPFWW75nxMQz1Yh7p9i+GBB2939Ktn/Mvq0Afcn
uaQN2pOPWI2MFgt2Aef5l9ARmDCQq3ijMIqT6e5YNmwe4Ho4jWRzhJ8/2Lgq7CgH
eILl/dPS1QgxCsGcSMBQNghi+4EkIoW4g3cEXpioSDUv+IiUHpsm0BmzDrbKRoQv
YGemcUHBG+CGbVneOwyyPcvpy8RfPwgaliRhPELrF16UKARQPvxi8FStILsKPFrO
b7heI43w0E8YE+o8m4Y5OAi+blGxRMCz8xIuvOuZFTv7bMyL6KHaTqynRqNu/QwY
Ny7d9qj0BJegIceyNaxcCr1wYkV2SuaUflmIpZjQZAVxqaxLXR7gkT+OG2D/OlbS
Ijvuxp11ie5RRHjsao2Y
=yFbE
-----END PGP SIGNATURE-----

--Sig_/Ljre1AhLXzX0AwMXVYgLnsm--
