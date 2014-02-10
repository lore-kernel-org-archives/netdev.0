From: Oleksij Rempel <linux@rempel-privat.de>
Subject: Re: [PATCH 09/28] Remove ATHEROS_AR231X
Date: Mon, 10 Feb 2014 13:17:55 +0100
Message-ID: <52F8C373.9060108@rempel-privat.de>
References: <1391971686-9517-1-git-send-email-richard@nod.at> <1391971686-9517-10-git-send-email-richard@nod.at> <52F7D480.1050106@hauke-m.de> <52F7DF21.70207@nod.at> <CAHNKnsS7Mv4ZhBWZa53go9L9nZimJ7_FG5HFJ9C3kkGMAEz-mA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="JDWAQLMAn1UQWTOqbFvCwbPqUUSJtjr7V"
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"open list:ATHEROS ATH5K WIR..." <linux-wireless@vger.kernel.org>,
	"open list:ATHEROS ATH5K WIR..." <ath5k-devel@lists.ath5k.org>,
	open@hauke-m.de,
	"list@hauke-m.de:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>,
	"antonynpavlov@gmail.com" <antonynpavlov@gmail.com>
To: Sergey Ryazanov <ryazanov.s.a@gmail.com>,
	Richard Weinberger <richard@nod.at>,
	Jonathan Bither <jonbither@gmail.com>,
	OpenWrt Development List <openwrt-devel@lists.openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHNKnsS7Mv4ZhBWZa53go9L9nZimJ7_FG5HFJ9C3kkGMAEz-mA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--JDWAQLMAn1UQWTOqbFvCwbPqUUSJtjr7V
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Am 10.02.2014 13:05, schrieb Sergey Ryazanov:
> 2014-02-10 0:03 GMT+04:00 Richard Weinberger <richard@nod.at>:
>> Am 09.02.2014 20:18, schrieb Hauke Mehrtens:
>>> On 02/09/2014 07:47 PM, Richard Weinberger wrote:
>>>> The symbol is an orphan, get rid of it.
>>>>
>>>> Signed-off-by: Richard Weinberger <richard@nod.at>
>>>> ---
>>>>  drivers/net/wireless/ath/ath5k/Kconfig | 10 +++++-----
>>>>  drivers/net/wireless/ath/ath5k/ath5k.h | 28 -----------------------=
-----
>>>>  drivers/net/wireless/ath/ath5k/base.c  | 14 --------------
>>>>  drivers/net/wireless/ath/ath5k/led.c   |  7 -------
>>>>  4 files changed, 5 insertions(+), 54 deletions(-)
>>>>
>>>
>>> This code is used in OpenWrt with an out of tree arch code for the
>>> Atheros 231x/531x SoC. [0] I do not think anyone is working on adding=

>>> this code to mainline Linux kernel, because of lack of time/interest.=

>>
>> Sorry, we don't maintain out of tree code.
>>
>=20
> Oleksij, Jonathan do you still working to make ar231x devices work
> with upstream, since your posts [1, 2]? Or may be someone from OpenWRT
> team would like to add upstream support?
>=20
> 1. https://lkml.org/lkml/2013/5/13/321
> 2. https://lkml.org/lkml/2013/5/13/358
>=20

Hi,
my current target was to provide barebox and openocd support.
- ar2313 is already upstream on barebox.
- ar2315-2318 (barebox) awaiting review by Anthony Pavlov.
- openocd (EJTAG) support is ready and i'll push it ASUP.

I hope Jonathan do kernel part. If not, i can provide some work, since i
have testing boards and expiriance on this hardware.

--=20
Regards,
Oleksij


--JDWAQLMAn1UQWTOqbFvCwbPqUUSJtjr7V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iF4EAREIAAYFAlL4w3MACgkQHwImuRkmbWmHEgEAmUpmT5YkDvKgx0v24yzb1wE3
lJRt74eb739s+Pc2mt8A/jnP8qfXkUwr7vSSBHUH9W266NrdqSTXjlWGgY3J3hgN
=MGbj
-----END PGP SIGNATURE-----

--JDWAQLMAn1UQWTOqbFvCwbPqUUSJtjr7V--
