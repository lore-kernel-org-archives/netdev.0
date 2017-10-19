From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [RFC PATCH] can: m_can: Support higher speed CAN-FD bitrates
Date: Thu, 19 Oct 2017 11:21:29 +0200
Message-ID: <832feb2d-3712-c394-805a-1ddabd89890e@pengutronix.de>
References: <20170818193947.27862-1-fcooper@ti.com>
 <4f8f6b64-b2a2-b9dc-665c-f1c155daf994@ti.com>
 <a7e301a7-bc54-c348-bdb1-b6a0af41665f@ti.com>
 <532e09ae-775d-e8aa-e468-78e148c650da@Microchip.com>
 <88d4ddc4-b786-0205-6852-56e93182a1c9@ti.com>
 <e3a7d9a1-d75c-a39e-f122-73fced02a1dc@gmx.net>
 <ed19ead3-d8f6-c027-74cf-8aee131c8a59@ti.com>
 <08432016-e733-b827-b9aa-bc359dd837f5@pengutronix.de>
 <7ba515d9-7710-c152-a55a-f995b7f3d49a@ti.com>
 <KL1PR0601MB20386197BA2733930329257BC3420@KL1PR0601MB2038.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="n8BUERSsBe5CWEuwg4E2TnHfWkLmuTS1N"
Cc: Wenyou Yang <wenyou.yang@atmel.com>,
        Dong Aisheng <b29396@freescale.com>,
        "Quadros, Roger" <rogerq@ti.com>
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
        Sekhar Nori <nsekhar@ti.com>,
        Franklin S Cooper Jr <fcooper@ti.com>,
        =?UTF-8?Q?Mario_H=c3=bcttel?= <mario.huettel@gmx.net>,
        "Yang, Wenyou" <Wenyou.Yang@Microchip.com>,
        "wg@grandegger.com" <wg@grandegger.com>,
        "socketcan@hartkopp.net" <socketcan@hartkopp.net>,
        "quentin.schulz@free-electrons.com"
        <quentin.schulz@free-electrons.com>,
        "edumazet@google.com" <edumazet@google.com>,
        "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <KL1PR0601MB20386197BA2733930329257BC3420@KL1PR0601MB2038.apcprd06.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--n8BUERSsBe5CWEuwg4E2TnHfWkLmuTS1N
Content-Type: multipart/mixed; boundary="rDlDCvUdepUFsCl5GElM3f6xTLBabsHPO";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
 Sekhar Nori <nsekhar@ti.com>, Franklin S Cooper Jr <fcooper@ti.com>,
 =?UTF-8?Q?Mario_H=c3=bcttel?= <mario.huettel@gmx.net>,
 "Yang, Wenyou" <Wenyou.Yang@Microchip.com>,
 "wg@grandegger.com" <wg@grandegger.com>,
 "socketcan@hartkopp.net" <socketcan@hartkopp.net>,
 "quentin.schulz@free-electrons.com" <quentin.schulz@free-electrons.com>,
 "edumazet@google.com" <edumazet@google.com>,
 "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Wenyou Yang <wenyou.yang@atmel.com>, Dong Aisheng <b29396@freescale.com>,
 "Quadros, Roger" <rogerq@ti.com>
Message-ID: <832feb2d-3712-c394-805a-1ddabd89890e@pengutronix.de>
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
 <KL1PR0601MB20386197BA2733930329257BC3420@KL1PR0601MB2038.apcprd06.prod.outlook.com>
In-Reply-To: <KL1PR0601MB20386197BA2733930329257BC3420@KL1PR0601MB2038.apcprd06.prod.outlook.com>

--rDlDCvUdepUFsCl5GElM3f6xTLBabsHPO
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: quoted-printable

On 10/19/2017 10:04 AM, Ramesh Shanmugasundaram wrote:
>>> Sounds reasonable. What's the status of this series?
>>
>> I have had some offline discussions with Franklin on this, and I am no=
t
>> fully convinced that DT is the way to go here (although I don't have t=
he
>> agreement with Franklin there).
>>
>> There are two components in configuring the secondary sample point. It=
 is
>> the transceiver loopback delay and an offset (example half of the bit =
time
>> in data phase).
>>
>> While the transceiver loopback delay is pretty board dependent (and th=
us
>> amenable to DT encoding), I am not quite sure the offset can be config=
ured
>> in DT because its not really board dependent.
>>
>> Unfortunately, offset calculation does not seem to be an exact science=
=2E
>> There are recommendations ranging from using 50% of bit time to making=
 it
>> same as the sample point configured. This means users who need to chan=
ge
>> the SSP due to offset variations need to change  their DT even without=

>> anything changing on their board.
>>
>> Since we have a netlink socket interface to configure sample point, I
>> wonder if that should be extended to configure SSP too (or at least th=
e
>> offset part of SSP)?
>=20
> +1
> > I also wonder how a default TDCO setting in DT would help.

For a given board with a given transceiver and layout and proper values
in the supplied DT the higher bitrates would work out of the box.

> Is the driver going to hard code the Tq settings as well for the
> most commonly used bitrate?

What's Tq in this context. Time Quanta?

> A link up start-up script (using netlink) would help setting a
> default TDCO along with other params if this is the main concern.

There are various ways to setup these values. Plain old start-up scripts
are one of them, systemd-networkd or network manager are others.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--rDlDCvUdepUFsCl5GElM3f6xTLBabsHPO--

--n8BUERSsBe5CWEuwg4E2TnHfWkLmuTS1N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlnobpkACgkQHv7KIOw4
HPYDTwgA1ug5EHH2ReYHarXX8fLayWXxu96sl5baLCL8rGZAa69Hi9/exejWEQmq
MF47+QFyqZIC4g9jTIf/yT9bGveExeIjPdMODTUZb1QLVnHY58RPWUepd8gE5QkY
WNz66pw7Nqr+ZKsXRpayG8lVeaY8IXgYx7gER1UShe4IMP12iIL1xUG8FJyWr0tT
AnxWIoXhoK4tiuGWvfKkvTvFRkN7FNotNRIgphdMxmV/rXa1pzjoeJrCOkPOzAQr
Fj1etqtqGLNGH67Pc/IyqZZVzDUpgtJbvHa4xdh9DD+b+BR2LlbWDHuUvoV0OpWd
WsEvndRPgguLIIwSGp0B01CNM/n3Jw==
=0FTE
-----END PGP SIGNATURE-----

--n8BUERSsBe5CWEuwg4E2TnHfWkLmuTS1N--
