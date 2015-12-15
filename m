From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH v5 4/4] net: diag: Support destroying TCP socketsr
Date: Tue, 15 Dec 2015 18:46:48 +0000
Message-ID: <33338363-CCDC-4401-8757-9A9F9802B9C8@intel.com>
References: <20151214.143739.879220917312503422.davem@davemloft.net>
 <1450199868-93712-1-git-send-email-lorenzo@google.com>
 <CAHo-OoxJHuuYqzpSmYkMKvXjmesMD=_G5_G5uBndNSPHTy8qBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_DE3C30B7-F10A-48F4-8F1B-DF53F60545C7";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Lorenzo Colitti <lorenzo@google.com>,
	Linux NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Hannes Frederic Sowa" <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Erik Kline <ek@google.com>, Tom Herbert <tom@herbertland.com>
To: =?utf-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:51468 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753880AbbLOSqu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2015 13:46:50 -0500
In-Reply-To: <CAHo-OoxJHuuYqzpSmYkMKvXjmesMD=_G5_G5uBndNSPHTy8qBw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_DE3C30B7-F10A-48F4-8F1B-DF53F60545C7
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8

Maciej =C5=BBenczykowski <zenczykowski@gmail.com> wrote:

> I'd tend to agree that reset or abort would be preferable to destroy.
> After all... the socket doesn't actually go away.

Or maybe terminate? Reset kind of implies to me that it may resume =
operation. Abort could be ok. I think terminate is somewhat more =
neutral, if that makes sense.

--
Mark Rustad, Networking Division, Intel Corporation

--Apple-Mail=_DE3C30B7-F10A-48F4-8F1B-DF53F60545C7
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJWcGAXAAoJEDwO/+eO4+5u3YoP/RX2im8SA9+JNui2fr4fgM4E
WCY0JXBJAtBdQC4lMxRJv0bRYhCl1crb4ansg6uqsGKE+zNmXeUoSjDu7Luo1QGf
mKrcBCaGvn3KgOSzceGX5YMn0cvJLjMhYRG4E1H/zNUGZGunr4jtmgc54ju1yIGe
3e3udM0Y+/yKELFkuapJj8bzRwF+EpR16T0x5XBMuiEdtEgaXZMwivu9lzuQgCfv
c+UmXDUGQnxph+HBV2XtEVxBbfZYoRiuYfaNFQUrwQztOYURpgOu6TIZdexYH9OW
1jrnaXh3g0ZBtY1ZcA7OxMkrIbvzNLFWf0m19su4AzucdhiXS+c24jO4UcVAhaZM
ajTMq5IQRl5WaGAm57YCPzMK+KZk7Erc37lhfJbalYCoG6yStaqkRk8xmXiL2XBI
Fp/XNN5dv4bbuKHQdZD8/VPfhd24ryS93mD00Sn2HsDsEVoHQhoXg+X9jEd4lXOe
QVDt+hRTojwlBxZ0p82ER1N8uZOu8Ew+i4mxqg4VWSr28KwyK8NrmAcBpTJoNV1r
6ZXP7N9Kgb3TGqbOZajuV6JQpTRRuM/X6fD1eklKWdgssT7Lzq54APzriCzrSBpl
gbqtez48nFxvTpBEv1T93Yz1U+kejTqgrsT1iqa2/w21po7A1FYDPnvYAPqRCN5a
erIczqP8RFu7WvgCQY0p
=q3LF
-----END PGP SIGNATURE-----

--Apple-Mail=_DE3C30B7-F10A-48F4-8F1B-DF53F60545C7--
