From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] ARM: OMAP: AM33XX: CAN: d_can: Add support for Bosch
 D_CAN controller
Date: Tue, 03 Apr 2012 14:49:48 +0200
Message-ID: <4F7AF1EC.1060802@pengutronix.de>
References: <1333456339-9372-1-git-send-email-anilkumar@ti.com> <4F7AF0C7.7020506@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD7ED27F555E02A3C4A67427F"
Cc: AnilKumar Ch <anilkumar@ti.com>, socketcan@hartkopp.net,
	m.kleine-budde@pengutronix.de, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	linux-kernel@vger.kernel.org, anantgole@ti.com, nsekhar@ti.com
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4F7AF0C7.7020506@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD7ED27F555E02A3C4A67427F
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 04/03/2012 02:44 PM, Wolfgang Grandegger wrote:
> On 04/03/2012 02:32 PM, AnilKumar Ch wrote:
>> This patch adds the support for Bosch D_CAN controller.
>>
>> Bosch D_CAN controller is a full-CAN implementation compliant to
>> CAN protocol version 2.0 part A and B. Bosch D_CAN user manual
>> can be obtained from: http://www.semiconductors.bosch.de/media/
>> en/pdf/ipmodules_1/can/d_can_users_manual_111.pdf
>>
>> D_CAN device is used on many SoCs like AM335x, DM8148 and DM813x
>> EVMs from TI, D_CAN details on AM335x can be accessed from:
>> http://www.ti.com/lit/ug/spruh73c/spruh73c.pdf
>>
>> D_CAN can be configurable for 16, 32, 64 and 128 message objects.
>> The driver implementation is based on 64 message objects.
>>
>> Following are the design choices made while writing the controller
>> driver:
>> 1. Interface Register set IF0 has be used for receive and IF1 is
>>    used for transmit message objects.
>> 2. Out of the total Message objects available, half of it are kept
>>    aside for RX purposes and the rest for TX purposes.
>> 3. NAPI implementation is such that both the TX and RX paths
>>    functions in polling mode.
>>
>> Signed-off-by: AnilKumar Ch <anilkumar@ti.com>
>=20
> Please explain why this CAN controller cannot be handled by the existin=
g
> C_CAN driver, eventually with some extensions. The register layout seem=
s
> almost identical, at least.

ACK.

Have a look at the recent at91_can driver. It has been improved to work
with a flexible number of message objects.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigD7ED27F555E02A3C4A67427F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk968fAACgkQjTAFq1RaXHOucACeKte8y+X35RKpQFlOdciPpCyD
Z+8An33/U+k4w4agLhVwlUXrHnPkLRjF
=JNBa
-----END PGP SIGNATURE-----

--------------enigD7ED27F555E02A3C4A67427F--
