From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] flexcan: disable bus error interrupts for the i.MX28
Date: Mon, 08 Oct 2012 11:31:31 +0200
Message-ID: <50729D73.3050409@pengutronix.de>
References: <5065A35B.3020702@grandegger.com> <20121007030858.GJ20231@S2101-09.ap.freescale.net> <50719647.4070404@grandegger.com> <7FE21149F4667147B645348EC60578850B2A361F@039-SN2MPN1-011.039d.mgd.msft.net> <507296F2.9010402@grandegger.com> <7FE21149F4667147B645348EC60578850B2A8D51@039-SN2MPN1-011.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB48DB519EAE3FF48644B1601"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux-CAN <linux-can@vger.kernel.org>,
	Hui Wang <jason77.wang@gmail.com>
To: Dong Aisheng-B29396 <B29396@freescale.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <7FE21149F4667147B645348EC60578850B2A8D51@039-SN2MPN1-011.039d.mgd.msft.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB48DB519EAE3FF48644B1601
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/08/2012 11:13 AM, Dong Aisheng-B29396 wrote:
>>> I just checked our ic guy of flexcan, it seems he also had no sense o=
f
>> this issue.
>>>
>>> Below is some version info what I got:
>>> Mx6s use FlexCAN3, with IP version 10.00.12.00
>>> Mx53 use FlexCAN2 (with glitch filter), with IP version 03.00.00.00
>>> Mx28 use FlexCAN2 (with glitch filter), with IP version 03.00.04.00
>>> Mx35 use FlexCAN2 (without glitch filter) , with IP version
>>> 03.00.00.00
>>> Mx25 use FlexCAN2 (without glitch filter), with IP version 03.00.00.0=
0
>>> I'm not sure if mx6q has such issue.
>>
>> OK, we need to find that out experimentally.
>>
> Our IC owner double checked the MX35 and MX53 IP and found the RX_WARN =
& TX_WARN
> Interrupt source actually are not connected to ARM.

Does this mean it's a SoC problem, not a problem of the ip core?

> That means flexcan will not trigger interrupt to ARM core even RX_WARN =
or TX_WARN
> Happens.
> This may be the root cause that why you cannot see RX_WARN interrupt if=
 not enable
> bus error interrupt on mx35.
> He also checked that mx6q has the rx/tx warning interrupt connected to =
arm.
> So we guess mx6q does not have this issue.
> Anyway, we can test to confirm.

What about mx25?

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigB48DB519EAE3FF48644B1601
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iEYEARECAAYFAlBynXMACgkQjTAFq1RaXHNrQQCfbozsaobAnfC5Zxet0ND1gqjo
K/wAniKbSZe3pfz2Wrlcddpv3PrM9Hil
=aTCj
-----END PGP SIGNATURE-----

--------------enigB48DB519EAE3FF48644B1601--
