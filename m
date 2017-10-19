From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [RFC PATCH] can: m_can: Support higher speed CAN-FD bitrates
Date: Thu, 19 Oct 2017 13:26:55 +0200
Message-ID: <0099eefa-32c8-a818-761c-667239d9ec3b@pengutronix.de>
References: <20170818193947.27862-1-fcooper@ti.com>
 <4f8f6b64-b2a2-b9dc-665c-f1c155daf994@ti.com>
 <a7e301a7-bc54-c348-bdb1-b6a0af41665f@ti.com>
 <532e09ae-775d-e8aa-e468-78e148c650da@Microchip.com>
 <88d4ddc4-b786-0205-6852-56e93182a1c9@ti.com>
 <e3a7d9a1-d75c-a39e-f122-73fced02a1dc@gmx.net>
 <ed19ead3-d8f6-c027-74cf-8aee131c8a59@ti.com>
 <08432016-e733-b827-b9aa-bc359dd837f5@pengutronix.de>
 <7ba515d9-7710-c152-a55a-f995b7f3d49a@ti.com>
 <848e965d-e6a1-8930-9064-0317563326c0@ti.com>
 <93c6d531-c38b-6f88-510f-59eb3e733b78@ti.com>
 <545ac690-10c8-b206-76dd-dbbe602eb6af@pengutronix.de>
 <a972cec1-3386-3ca3-ace3-175e1cabd286@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="RlbSnx2VD649caxfc10AqDuAdFdPWaGJK"
Cc: Wenyou Yang <wenyou.yang@atmel.com>,
        Dong Aisheng <b29396@freescale.com>,
        "Quadros, Roger" <rogerq@ti.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        Sekhar Nori <nsekhar@ti.com>,
        Franklin S Cooper Jr <fcooper@ti.com>,
        =?UTF-8?Q?Mario_H=c3=bcttel?= <mario.huettel@gmx.net>,
        "Yang, Wenyou" <Wenyou.Yang@Microchip.com>, wg@grandegger.com,
        quentin.schulz@free-electrons.com, edumazet@google.com,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a972cec1-3386-3ca3-ace3-175e1cabd286@hartkopp.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--RlbSnx2VD649caxfc10AqDuAdFdPWaGJK
Content-Type: multipart/mixed; boundary="scGCN2bGVAdnC6wLLugoqHABEJRHeOfFt";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>, Sekhar Nori <nsekhar@ti.com>,
 Franklin S Cooper Jr <fcooper@ti.com>, =?UTF-8?Q?Mario_H=c3=bcttel?=
 <mario.huettel@gmx.net>, "Yang, Wenyou" <Wenyou.Yang@Microchip.com>,
 wg@grandegger.com, quentin.schulz@free-electrons.com, edumazet@google.com,
 linux-can@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Cc: Wenyou Yang <wenyou.yang@atmel.com>, Dong Aisheng <b29396@freescale.com>,
 "Quadros, Roger" <rogerq@ti.com>
Message-ID: <0099eefa-32c8-a818-761c-667239d9ec3b@pengutronix.de>
Subject: Re: [RFC PATCH] can: m_can: Support higher speed CAN-FD bitrates
References: <20170818193947.27862-1-fcooper@ti.com>
 <4f8f6b64-b2a2-b9dc-665c-f1c155daf994@ti.com>
 <a7e301a7-bc54-c348-bdb1-b6a0af41665f@ti.com>
 <532e09ae-775d-e8aa-e468-78e148c650da@Microchip.com>
 <88d4ddc4-b786-0205-6852-56e93182a1c9@ti.com>
 <e3a7d9a1-d75c-a39e-f122-73fced02a1dc@gmx.net>
 <ed19ead3-d8f6-c027-74cf-8aee131c8a59@ti.com>
 <08432016-e733-b827-b9aa-bc359dd837f5@pengutronix.de>
 <7ba515d9-7710-c152-a55a-f995b7f3d49a@ti.com>
 <848e965d-e6a1-8930-9064-0317563326c0@ti.com>
 <93c6d531-c38b-6f88-510f-59eb3e733b78@ti.com>
 <545ac690-10c8-b206-76dd-dbbe602eb6af@pengutronix.de>
 <a972cec1-3386-3ca3-ace3-175e1cabd286@hartkopp.net>
In-Reply-To: <a972cec1-3386-3ca3-ace3-175e1cabd286@hartkopp.net>

--scGCN2bGVAdnC6wLLugoqHABEJRHeOfFt
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: quoted-printable

On 10/19/2017 01:14 PM, Oliver Hartkopp wrote:
>>>>> Since we have a netlink socket interface to configure sample point,=
 I
>>>>> wonder if that should be extended to configure SSP too (or at least=
 the
>>>>> offset part of SSP)?
>=20
> +1 too

The struct can_bittiming in defined in uapi, so we have to keep ABI
compatibility in mind.

>>>> Sekhar is right that ideally the user should be able to set the SSP =
at
>>>> runtime. However, my issue is that based on my experience CAN users
>>>> expect the driver to just work the majority of times. For unique use=

>>>> cases where the driver calculated values don't work then the user sh=
ould
>>>> be able to override it. This should only be done for a very small
>>>> percentage of CAN users. Unless you allow DT to provide a default SS=
P
>>>> many users of MCAN may find that the default SSP doesn't work and mu=
st
>>>> always use runtime overrides to get anything to work. I don't think =
that
>>>> is a good user experience which is why I don't like the idea.
>>>
>>> Fair enough. But not quite sure if CAN users expect CAN-FD to "just
>>> work" without doing any bittiming related setup.
>>
>>  From my point of view I'd rather buy a board from a HW vendor where
>> CAN-FD works, rather than a board where I have to tweak the bit-timing=

>> for a simple CAN-FD test setup.
>>
>> As far as I see for the m_can driver it's a single tuple: "bitrate > 2=
=2E5
>> MBit/s -> 50%". Do we need an array of tuples in general?
>>
>> If good default values are transceiver and board specific, they can go=

>> into the DT. We need a generic (this means driver agnostic) binding fo=
r
>> this. If this table needs to be tweaked for special purpose, then we c=
an
>> add a netlink interface for this as well. >
>> Comments?
>=20
> By now we calculate reasonable default values (e.g. for SP and SJW), yo=
u=20
> can override by setting alternative values via netlink configuration.
>=20
> I would tend to stay on this approach and not hide these things in DTs =
-=20
> just because of someone wants to initialize his specific interface 'eas=
ier'.

If the values are not board specific, then it makes no sense to put them
into the DT.

> One tool, one place is IMHO still the best option.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--scGCN2bGVAdnC6wLLugoqHABEJRHeOfFt--

--RlbSnx2VD649caxfc10AqDuAdFdPWaGJK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlnoi/8ACgkQHv7KIOw4
HPaEhAf+NAKyq74B5+59H7qlQQwXg+Z+s2/zvUOYbuMnBYSoukpAxMFm7557BJad
2eyc1RR6KPGDwbdhRbg7364J/pH8JOzJMm7z8gQHDXDiOVp+gZ3VAxOyKjSqdYgl
cAY5TcZJ2PApXSi/SeUtHgxEm4nlYAJTsBS8BLJjpADVQoC/U4lYgMfDjKQxpBAf
G72MCwFe7YjTkLptcVf8uoI98jgHnf4q30zpHcawPgCydOOK/Mj0kEni6EoOcvaI
+ve46v0VqeQaAvOY93qO7+lc4FihDaqnK6H5hHWfs1/BucwFB+gLtr/VLKamVCSe
s6uSuzq6QhaFW7A/oFoEqs8jYdPuHg==
=sdv2
-----END PGP SIGNATURE-----

--RlbSnx2VD649caxfc10AqDuAdFdPWaGJK--
