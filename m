From: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <uwe@kleine-koenig.org>
Subject: Re: [PATCH net-next 1/2] net: dsa: make "label" property optional for
 dsa2
Date: Sat, 7 Jan 2017 21:28:30 +0100
Message-ID: <81c94b88-e2a5-a11d-63d0-c84a7f0e77b5@kleine-koenig.org>
References: <20170106220043.21280-1-vivien.didelot@savoirfairelinux.com>
 <20170106220043.21280-2-vivien.didelot@savoirfairelinux.com>
 <20170106222008.GC10626@lunn.ch>
 <0dbf9730-2409-30f9-e9e4-946fe7fec413@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="7TMnCFn7onxSE9LDXiNhkCFN5o0aVXH26"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0dbf9730-2409-30f9-e9e4-946fe7fec413@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--7TMnCFn7onxSE9LDXiNhkCFN5o0aVXH26
Content-Type: multipart/mixed; boundary="22brLTkaMBGIWUXl43P6Apgh0fmsq0k9e";
 protected-headers="v1"
From: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <uwe@kleine-koenig.org>
To: Florian Fainelli <f.fainelli@gmail.com>, Andrew Lunn <andrew@lunn.ch>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 kernel@savoirfairelinux.com, "David S. Miller" <davem@davemloft.net>
Message-ID: <81c94b88-e2a5-a11d-63d0-c84a7f0e77b5@kleine-koenig.org>
Subject: Re: [PATCH net-next 1/2] net: dsa: make "label" property optional for
 dsa2
References: <20170106220043.21280-1-vivien.didelot@savoirfairelinux.com>
 <20170106220043.21280-2-vivien.didelot@savoirfairelinux.com>
 <20170106222008.GC10626@lunn.ch>
 <0dbf9730-2409-30f9-e9e4-946fe7fec413@gmail.com>
In-Reply-To: <0dbf9730-2409-30f9-e9e4-946fe7fec413@gmail.com>

--22brLTkaMBGIWUXl43P6Apgh0fmsq0k9e
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello,

On 01/06/2017 11:47 PM, Florian Fainelli wrote:
> On 01/06/2017 02:20 PM, Andrew Lunn wrote:
>>> If one wants to rename an interface, udev rules can be used as usual.=

>>
>> Hi Vivien
>>
>> Do you have some examples?
>>
>> A quick look at udevadm info suggests we can use
>>
>> ATTR{phys_port_id} and ATTR{phys_switch_id}
>>
>> Humm, it would be nice to know why the second switch has a
>> phys_switch_id of 01000000.
>=20
> Well, that's a combination of being on a little endian system and using=

> %*phN as a printk formatter, and the type being 32-bit long (int). I
> agree this does not feel natural, but since this is sysfs (so ABI in a
> way), it's going to be though to change now.

for most subsystems I know the internally used (and more or less
automatically determined) numbers are not to be considered stable.
For example the GPIO made it possible to let userspace work with GPIOs
without knowing (or having to determine) the gpio numbers.

I don't know if/how this applies here.

Best regards
Uwe



--22brLTkaMBGIWUXl43P6Apgh0fmsq0k9e--

--7TMnCFn7onxSE9LDXiNhkCFN5o0aVXH26
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEfnIqFpAYrP8+dKQLwfwUeK3K7AkFAlhxT3EACgkQwfwUeK3K
7AkRNAf/UHIQTxlqMRRZkhQ89B6vvs1bYR77jT0xaNHGatkKsWFYQEvT8X5bIiY3
gZWJ2+E9vjb3exqtEzFLFn6zL5QZts0qLBzYM3Nw30kYZXAHPj92sd49KjRCo/Jw
IezllbL4BEEckBVK9+yLzR36+mPx0Q6Or8cGUTtXeMm2boYS3xOzjRFb2Od7/aGV
6MjhKOjma3223xwxqBOS9Jmceerbz6BaysSCAHCaV0y46giNEatHNA+NPuMCQ9kX
7DrWhUgWdHAgconLIgcyK0OpNZxN5FN4+U/FtG83DCU9AUr2OvO1G32EzeqzT0SX
V2uKgXEclGxabLtzZ9piJ1cnAMstUw==
=CmIY
-----END PGP SIGNATURE-----

--7TMnCFn7onxSE9LDXiNhkCFN5o0aVXH26--
