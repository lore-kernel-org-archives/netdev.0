From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Wed, 02 May 2012 14:53:15 +0100
Message-ID: <1335966795.8274.129.camel@deadeye>
References: <20120427094637.GV3157@wantstofly.org>
	 <CA+icZUXNZ=exTnR=OgD_9bpt_0s-KnR+v-K6u+XzQr4HBoTQHQ@mail.gmail.com>
	 <20120427095842.GW3157@wantstofly.org>
	 <CA+icZUWuynSaPE4pdxzoP783pw7r=5x27ewXN_pkR5VS=0kKUg@mail.gmail.com>
	 <20120427101732.GX3157@wantstofly.org>
	 <CA+icZUUnJPeDmL9xXfvj62an40bXwwaOnrJmxmLN_cBt9PyCZA@mail.gmail.com>
	 <CA+icZUV76wSBj88EpzmWbO=u2dP23yi5P98nN2KZehBUni9mEg@mail.gmail.com>
	 <20120427185809.GZ3157@wantstofly.org>
	 <CA+icZUWQmCRdjucb4+Nf24_zbJ4fzzp7zjqhKjXE6U01rppDfA@mail.gmail.com>
	 <CA+icZUXSaEMA=KbQP9UQcU6ZMBh8QD2sv-O=6r_Ly8is==gvSA@mail.gmail.com>
	 <20120501125102.GN3157@wantstofly.org>
	 <CA+icZUV=qtXwVxb+uvQJcsza0y+6k2LHJFFPnECY0M=QWBexaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-GtiMnukx0IbjvkdSusAz"
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, lautriv <admin@coldplug.net>,
	Jim Cromie <jim.cromie@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: sedat.dilek@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+icZUV=qtXwVxb+uvQJcsza0y+6k2LHJFFPnECY0M=QWBexaQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-GtiMnukx0IbjvkdSusAz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-05-01 at 15:54 +0200, Sedat Dilek wrote:
> On Tue, May 1, 2012 at 2:51 PM, Lennert Buytenhek
> <buytenh@wantstofly.org> wrote:
> > On Sun, Apr 29, 2012 at 12:25:21AM +0200, Sedat Dilek wrote:
> >
> >> > On 1st sight, logs look fine:
> >> >
> >> > [21:52:52] <lautriv> [    6.050967] ieee80211 phy0: 88w8361p v4,
> >> > 00173f3bdde3, STA firmware 2.1.4.25
> >> >
> >> > But WLAN connection is not that fast and stable as lautriv reports
> >> > (several abnormalities were observed).
> >> >
> >> > I requested a tarball which includes:
> >> > * dmesg (Linux-3.3.3)
> >> > * e_n_a (/etc/network/interfaces)
> >> > * ifconfig output
> >> > * iwconfig output
> >> > * iw_phy output
> >> > * ps_axu (WPA) output
> >> >
> >> > lautriv will be so kind to be around on #linux-wireless/Freenode the
> >> > next days (UTC+2: German/Swiss local-time).
> >> > Just ping him.
> >> >
> >> > Hope you have fun, together!
> >> >
> >> > - Sedat -
> >>
> >> A new tarball from lautriv with same outputs as before, but now tested
> >> with Linux-3.4-rc4.
>=20
> [ CC hauke (OpenWrt) and Ben Hutchings (linux-firmware maintainer) ]
>=20
> > The output looks good enough for me to ACK adding the PCI ID.
> >
> > Can the firmware being used here be submitted to the linux-firmware
> > git tree?
>=20
> I can't say much about the firmware [1] inclusion or the procedure of
> it into linux-firmware [2].
> Maybe, Ben can explain the procedure and what has to be considered
> before inclusion in linux-firmware.
> The original firmware and helper images were extracted from a Netgear
> Windows driver [1].
[...]

Even assuming that the original driver binary is freely redistributable,
it's not at all clear that these extracted blobs would be.

If there's some difficulty in getting a sensible licence for the
firmware, you can consider providing a tool to do this extraction, as
has been done for some other drivers whose vendors don't provide the
firmware blobs alone.  However, as yet, linux-firmware doesn't include
any such extraction tools and I would need to discuss such an addition
with David (and maybe other distribution maintainers).  Hopefully that
won't be necessary, though.

Ben.

--=20
Ben Hutchings
Design a system any fool can use, and only a fool will want to use it.

--=-GtiMnukx0IbjvkdSusAz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT6E8S+e/yOyVhhEJAQoDFw/9GyA95qJsXLlkw6DNrWfHSBbRpfBsRBsA
U8i5Pf6+dN1J+h9WEN1uqF+/+EECSSaGfNDD26bZlNEjVkeH+M8c4dSFRUt/IaWq
bOpgDNKdwXF6fHlEdugzxWyRW5Z512xJ1KJ6umNmxIqXw0BNXbJJmUFkMhK8Vf2U
eVsYKBhOS/4MnR7A5+9HWPSBoPt34IOXsA4PVWGIQ9u3mNNSZL3cqrn5sa0aCW70
ImuFSOvyAKFWgn7047EvJ/9nvKHXMfJc0YOdIkW/FGMZo1jh6C+/7bTmp+j1uxw6
gqlResiVfmADCa1cJFwEprBF7xwyplDSsLDAG53UOtefRTYCGzNwCaNQH9cCepwI
w6ap/OfT5SODm6saY+iJ0BSSqOYOAFJt0Kp5Yutj0LpVxcC7Gz94BMPGDebV5iut
vZz7yJi6dp5k7DI0XIJOFm/xWESWfxhlNltolQGoAZasZwvFDVSzxaVXMXAy9vtt
Gd5/Yh9AIAg6iqOHfR/3GG3TCrH4bB9xCJyRWz3wM3F+y/QxBY9W29L2i2DZghoO
nRzrfQUpAKGMWH7QJ1ilbopPgss0FnD7DjVMfp1yb1HXUbjFUjSUkj64lvrxEb95
EDVsV2h0qxxrttcUo6+MvIdUO7qPpnNMLHst5XKFmESFneUZZ0+6YpUaugIKMCsl
aMTJ4t6gkbA=
=7Ts2
-----END PGP SIGNATURE-----

--=-GtiMnukx0IbjvkdSusAz--
