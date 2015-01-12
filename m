From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 4/4] can: kvaser_usb: Retry first bulk transfer on
 -ETIMEDOUT
Date: Mon, 12 Jan 2015 11:25:28 +0100
Message-ID: <54B3A118.5000907@pengutronix.de>
References: <20141223154654.GB6460@vivalin-002> <20150111200544.GA8855@linux> <20150111201116.GB8855@linux> <20150111201519.GC8855@linux> <20150111203612.GA8999@linux> <20150111204508.GB8999@linux> <54B2E23E.1090108@pengutronix.de> <20150112101407.GA9213@linux>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="9v9aGvt0WxUxsUVtwToHBBAcGdKSKKAIF"
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Linux-USB <linux-usb@vger.kernel.org>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20150112101407.GA9213@linux>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--9v9aGvt0WxUxsUVtwToHBBAcGdKSKKAIF
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/12/2015 11:14 AM, Ahmed S. Darwish wrote:
> On Sun, Jan 11, 2015 at 09:51:10PM +0100, Marc Kleine-Budde wrote:
>> On 01/11/2015 09:45 PM, Ahmed S. Darwish wrote:
>>> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>>>
>>> (This is a draft patch, I'm not sure if this fixes the USB
>>> bug or only its psymptom. Feedback from the linux-usb folks
>>> is really appreciated.)
>>>
>>> When plugging the Kvaser USB/CAN dongle the first time, everything
>>> works as expected and all of the transfers from and to the USB
>>> device succeeds.
>>>
>>> Meanwhile, after unplugging the device and plugging it again, the
>>> first bulk transfer _always_ returns an -ETIMEDOUT. The following
>>> behaviour was observied:
>>>
>>> - Setting higher timeout values for the first bulk transfer never
>>>   solved the issue.
>>>
>>> - Unloading, then loading, our kvaser_usb module in question
>>>   __always__ solved the issue.
>>>
>>> - Checking first bulk transfer status, and retry the transfer
>>>   again in case of an -ETIMEDOUT also __always__ solved the issue.
>>>   This is what the patch below does.
>>>
>>> - In the testing done so far, this issue appears only on laptops
>>>   but never on PCs (possibly power related?)
>>>
>>> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>>
>> Does this patch apply apply between 3 and 4? If not, please re-arrange=

>> the series. As this is a bug fix, patches 1, 2 and 4 will go via
>> net/master, 3 will go via net-next/master.
>=20
> Since no one complained earlier, I guess this issue only affects
> USBCAN devices. That's why I've based it above patch #3: adding
> USBCAN hardware support.
>=20
> Nonetheless, it won't do any harm for the current Leaf-only
> driver. So _if_ this is the correct fix, I will update the commit
> log, refactor the check into a 'do { } while()' loop, and then
> base it above the Leaf-only net/master fixes on patch #1, and #2.
>=20
> Any feedback on the USB side of things?

Maybe you have to change the subject of this patch to be more visible on
the USB list and/or add the right USB people on Cc.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--9v9aGvt0WxUxsUVtwToHBBAcGdKSKKAIF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUs6EYAAoJECte4hHFiupU2FQP/0k3HDCuGX9VlOIC2bGhNSMZ
O7h0l9q35wvi6x2nD1mpsv0rNQUYE4HnZkFrq3ci75i6w6PB92KbOwwXrxwr4yZU
PwMepf1NLYsocGWVyszBXtsqEx0c1DDBhMA6mh/XI3ouG9kGeIuIKndEIE+1Hs20
oDx0U1dD9buQg7TjKxTq9qlHS/hluLCZx1GRZ4tXDiBgi+VNU7/FfLQ0tYtywTBx
fzC6KCn4rAyeVMIIdHNg2me53TJcLw8SVRtkDXbKphZFydTbAWAwhvdsqqxAYr9q
abSyySbjfLa+JHS2dgsb7P38NwqAU+O0LuYLJdMPvHG6EK6pAzghe6Ptk0e5qSw4
JkGg5l0+2WWHvfaimZ/WL9SMxOa9J5Uh/X6VUnjl8bwoXFXqCV+iZU0XEADN7IJq
m2Gr1EqpX9NooH2MHuXpcnBv3PXzePlj0DAcegqhtlLIHDp0+DLNQPWEH9rxc/7v
QfAHPlS5xAidiydAmsbXkxOIu3cuFCsecmmx2tKEnsep1tvQKW9wtjGW5W7mSZ6y
pFsLfbDsQSoKtk+mp+IovsS0QDSDdSm2uBlyDxiJTtMC0irOBfWdpa9+t4n8WDNa
CogWYL4cG/CrBfTwitb9Qr7WKD8SY5O6N67jbbZ+ELDKm1TiGyrF6UtIQQQoBMJQ
zH8xPg8sKWpaY2yt9J4n
=AwgF
-----END PGP SIGNATURE-----

--9v9aGvt0WxUxsUVtwToHBBAcGdKSKKAIF--
