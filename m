From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH V2] r8152: add Linksys USB3GIGV1 id
Date: Thu, 28 Sep 2017 22:28:04 +0000
Message-ID: <EE09EDA8-B6E9-4BEB-882C-C5435EDA8E41@intel.com>
References: <20170926010925.114436-1-grundler@chromium.org>
 <CAD=FV=Uk=oPuF7LMhHPM_CTPNEa_G26R6Ce023pTNCCsyqts1Q@mail.gmail.com>
 <1506496556.28482.3.camel@suse.com>
 <CANEJEGtEfxR+8n3tRtsci=4Gtyhy021Z-DRvEgXPGFUqYK2u7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
        boundary="Apple-Mail=_D8B96E24-7612-4449-AA80-A0DE93A8A627";
        protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Oliver Neukum <oneukum@suse.com>,
        Doug Anderson <dianders@chromium.org>,
        "David S . Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Hayes Wang <hayeswang@realtek.com>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-usb <linux-usb@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Grant Grundler <grundler@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANEJEGtEfxR+8n3tRtsci=4Gtyhy021Z-DRvEgXPGFUqYK2u7Q@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Apple-Mail=_D8B96E24-7612-4449-AA80-A0DE93A8A627
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


> On Sep 27, 2017, at 9:39 AM, Grant Grundler <grundler@chromium.org> =
wrote:
>=20
> On Wed, Sep 27, 2017 at 12:15 AM, Oliver Neukum <oneukum@suse.com> =
wrote:
>> Am Dienstag, den 26.09.2017, 08:19 -0700 schrieb Doug Anderson:
>>>=20
>>> I know that for at least some of the adapters in the CDC Ethernet
>>> blacklist it was claimed that the CDC Ethernet support in the =
adapter
>>> was kinda broken anyway so the blacklist made sense.  ...but for the
>>> Linksys Gigabit adapter the CDC Ethernet driver seems to work OK, =
it's
>>> just not quite as full featured / efficient as the R8152 driver.
>>>=20
>>> Is that not a concern?  I guess you could tell people in this
>>> situation that they simply need to enable the R8152 driver to get
>>> continued support for their Ethernet adapter?
>>=20
>> Hi,
>>=20
>> yes, it is a valid concern. An #ifdef will be needed.
>=20
> Good idea - I will post V3 shortly.
>=20
> I'm assuming you mean to add #ifdef CONFIG_USB_RTL8152 around the
> blacklist entry in cdc_ether driver.

Shouldn't that be an #if IS_ENABLED(...) test, since that seems to be =
the proper way to check configured drivers.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_D8B96E24-7612-4449-AA80-A0DE93A8A627
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJZzXd0AAoJEDwO/+eO4+5udm0P/2GW3yE04k3otZCX+aWdLIxS
Nk6KN9xE1/fRcfi3gFCqR571R62fuetr7fdNR9e4Y0fqbao5u7Jd3thKQXT4Yq4O
jSHK+yr4sx7LlHb5JxoOI+BJb0eE3R4wQT6Dvl9dZuror9Wcb4X+KCydnLpuf0gZ
XiLx5WcWEu/goeiRW02wTHR1EEBU+QZ7P0xy1R3bb+Ej5q1MA3i5NZIkf8G6yuI5
sXNIQTkq31mUpu4H7phPZnvSvUxYEYWoFOPLuyIE/rKIeuSVsr/Or6jpgeE3SUSU
MPSJucAxtkQC5kOCVAICgabfPA6nItDftDVaiKKfHBYGhVAJB3z/hK9SiS5MOrtP
aX212E2GgZVQgKcFwMZLGsvbGu364lLraXFY7QLjagGLR3ECZuQxA0edQ64vCqx3
ZgUAhfwlhaSd/fTplVBHR2OdWkbx2z/AeAqty+FrupRfePeEYCPGKzgHkehwLpaC
8IyriYK4uOy8qZq7wrffVfiRzvYSA8GYz22fKlf/kHT4o6uuBrmgVVFyrAkeiIKs
xLj88onpvn6zuqlMWyotTbHZTi91pd1ROh4Jry9pAgY8XcTuHnqX5iLKywJNaiD6
McHQh74zXfCbw2OLksVtA/pbB35Av5sLUBNfdOiWjdCy07ka912oxKJcDEQ+JsgI
i9j0+40NYUUolfTweFB0
=Hx2w
-----END PGP SIGNATURE-----

--Apple-Mail=_D8B96E24-7612-4449-AA80-A0DE93A8A627--
