From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: Enable xilinx driver for all ARCHs
Date: Mon, 09 Mar 2015 16:56:24 +0100
Message-ID: <54FDC2A8.2010301@pengutronix.de>
References: <4096fa4ceae72817d8e64d9a1da738038a5c864a.1425890926.git.michal.simek@xilinx.com> <54FD5EE1.6050402@pengutronix.de> <BY2FFO11FD001BD9CFD92C94214501BB8E21B0@BY2FFO11FD001.protection.gbl> <54FD641C.7090607@pengutronix.de> <BY2FFO11FD0060B11FE9C9305D5DFD12BE21B0@BY2FFO11FD006.protection.gbl> <54FD6E42.6070206@pengutronix.de> <1425909239.23920.60.camel@chaos.site> <54FDA662.8020801@pengutronix.de> <BY2FFO11FD023D29C02DAF9CCBDC40386E21B0@BY2FFO11FD023.protection.gbl> <BY2FFO11FD0539B08FEA25A4338C347898C1B0@BY2FFO11FD053.protection.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="q3jhJwn44h2amAQONvpGN1C1EnFjTAdDB"
Cc: Jean Delvare <jdelvare@suse.de>, linux-kernel@vger.kernel.org,
	monstr@monstr.eu, Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: =?UTF-8?Q?S=c3=b6ren_Brinkmann?= <soren.brinkmann@xilinx.com>,
	Michal Simek <michal.simek@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BY2FFO11FD0539B08FEA25A4338C347898C1B0@BY2FFO11FD053.protection.gbl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--q3jhJwn44h2amAQONvpGN1C1EnFjTAdDB
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/09/2015 04:51 PM, S=C3=B6ren Brinkmann wrote:
>>> Sounds reasonable. Michael, make it so.
>>
>> I have sent v2 which add arm64 to Kconfig and I am keeping just depend=
ency on
>> ARCH_ZYNQ not all ARM platforms.
>=20
> You could (and some people do that with some devices) use these devices=

> from x86(_64) if you plug your FPGA/Zynq platform into a PCIe slot
> (FWIW, this should work for any platform that supports PCIe). I think w=
e
> just had somebody sending patches to enable the Zynq UART, IIRC, for x8=
6.

Nice :)

The "depends on" can easily be changed with once there's PCIe glue code
for the driver.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--q3jhJwn44h2amAQONvpGN1C1EnFjTAdDB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJU/cKuAAoJECte4hHFiupUFGcQAILvkTRI6pdrZYq/ea/cE8N4
gLyTqXxTKR+5Lx3WClV54X9YW509LxWc6b+V9Sw6xL/QvbG2kvJKBnfGLvsLSThl
wPMyB3YfYll1VNEy5YKAhZijHqBrPUQ0xTGG7MGdt2euXubdrKt3VMEB4PW8wXxo
Ypt1+5NJDhhF8uO9yzYA3KeWUhmd4bnH6x8w/4HIvnPYjsM/TmmD5PGjdYxlO2Hv
XvWvCIlz6fnU6U9YtjcEpAeradIVTNwE1sxSGg7lFxO6B5ofT2KbtpRlRT5poJkb
zz8qdcES2Dn/e5TMwxYE5LjPTthc8Jx1EbqeJdr3KZcV+BNGZk7mE4O3NaZNACu3
aKMwN6PoIllZDVhedtwyXY69ZcYi31CW6bSrEn+eSxWhK9mQBWwg3vRC5Q73waWN
HBh0BrQI+kAgaH+kU1I73hhtHoUiP080gl2BqSaywv9Wh34p85AcpVCy85ocomCI
PinCN0rRfDG9naQMihHK04AlOP8LG4Ypk0mVzdaKThRS2GkWNudhaRGBYqWvXUML
JWCtD1igMYp1n40xcg6aEuz6MkM8AOpxYkJge31mNP4v2lK4ulOYW+3i7sUPmP7P
MeBsMvr7k7nJGHT4luatk8M+K5j5eD1oT1RhWwb4Xyf8UzHohBgKeaV1fqaV/SGV
G3lQVYw8kk1VJOm8hACr
=JftJ
-----END PGP SIGNATURE-----

--q3jhJwn44h2amAQONvpGN1C1EnFjTAdDB--
