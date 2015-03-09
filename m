From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: Enable xilinx driver for all ARCHs
Date: Mon, 09 Mar 2015 10:56:18 +0100
Message-ID: <54FD6E42.6070206@pengutronix.de>
References: <4096fa4ceae72817d8e64d9a1da738038a5c864a.1425890926.git.michal.simek@xilinx.com> <54FD5EE1.6050402@pengutronix.de> <BY2FFO11FD001BD9CFD92C94214501BB8E21B0@BY2FFO11FD001.protection.gbl> <54FD641C.7090607@pengutronix.de> <BY2FFO11FD0060B11FE9C9305D5DFD12BE21B0@BY2FFO11FD006.protection.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="OIdjbDHu73uSig5EAG7pPhOC3jFrBLtvl"
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, Jean Delvare <jdelvare@suse.de>
To: Michal Simek <michal.simek@xilinx.com>,
	linux-kernel@vger.kernel.org, monstr@monstr.eu
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <BY2FFO11FD0060B11FE9C9305D5DFD12BE21B0@BY2FFO11FD006.protection.gbl>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--OIdjbDHu73uSig5EAG7pPhOC3jFrBLtvl
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/09/2015 10:52 AM, Michal Simek wrote:
> On 03/09/2015 10:13 AM, Marc Kleine-Budde wrote:
>> On 03/09/2015 09:58 AM, Michal Simek wrote:
>>> On 03/09/2015 09:50 AM, Marc Kleine-Budde wrote:
>>>> On 03/09/2015 09:48 AM, Michal Simek wrote:
>>>>> Remove Kconfig dependency and enable driver for
>>>>> all ARCHs.
>>>>>
>>>>> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
>>>>> Acked-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>
>>>>> ---
>>>>>
>>>>> Test for all archs done by Kbuild test robot without any problem.
>>>>> ---
>>>>>  drivers/net/can/Kconfig | 1 -
>>>>>  1 file changed, 1 deletion(-)
>>>>>
>>>>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
>>>>> index 98d73aab52fe..f690c3fb3088 100644
>>>>> --- a/drivers/net/can/Kconfig
>>>>> +++ b/drivers/net/can/Kconfig
>>>>> @@ -131,7 +131,6 @@ config CAN_RCAR
>>>>> =20
>>>>>  config CAN_XILINXCAN
>>>>>  	tristate "Xilinx CAN"
>>>>> -	depends on ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST
>>>>
>>>> I think that's what COMPILE_TEST ist for?
>>>
>>> For compilation yes but not for enabling. Currently this driver
>>> can be also used on ARM64 that's why people suggesting directly
>>> to remove dependency on arch and then COMPILE_TEST can be removed
>>> too.
>>
>> In the past (May 2014) I had people complaining that certain ARM SoC
>> specific drivers are enabled on ARM in general, not just on that SoC. =
As
>> I'm not following arm64 in detail, has the notion of using depends on
>> ARCH changes since then?
>>
>>> Or do you want me to change description to mention that this is for
>>> ARM64 enabling?
>>
>> Given this is consensus, a remark to ARM64 would be appreciated. :)
>=20
> David has applied this patch which is in general just the same as this =
one.
>=20
> (linux-next) Remove architecture dependency
> 28811a8c00fe0d899b8a544421f3b4947425d5e8
>=20
> Mark Brown has suggested to do so for spi and don't check architecture =
at
> all.
> I have also sent similar patch for watchdog driver too.
>=20
> I think it is up to you if you want to add ARM64 to Kconfig or just rem=
ove
> that arch dependencies.
> To be honest my goal is to enable this driver for ARM64.
> Please tell me what way you prefer.

I like the idea of removing the depends on ARCH completely. Jean, what
do you think?

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--OIdjbDHu73uSig5EAG7pPhOC3jFrBLtvl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJU/W5NAAoJECte4hHFiupUfewP/056vagDZzZdeZ3q8dC0P3Hm
QHMC3iXDbUPaMjnHypAeLHQrBy2P44KBPoU6RXpoVtPYKXTXnQHwIcH9WE2mhIL0
x7Mt1iVH08EUAK7HqCgj2Mn0qRUkjZCmWyLTW1mmFlTurUfWweLQyhy5GM99RNTe
axanddfrs+7+KArDCr98rIbtK4kDmae/Mevrm9qICk0D/uqXNNUEpRa9oCpwbNSM
AeolO5IU9drcFCXeZGW8xoMzmZBhczpW5CYGNRlIAIMOu7J7VP8y5fOw0/VpdN9P
DeOwWAQPi38u4qpYjvVAOXYyv15Ti+Uz5WvA8jJYibkOunl7yggG/rjMCTpZoLWF
Mezfgi4cyRqTyv/GsHImrq+o6DaL2IcfShED5rVIP1I3H7SrSCxHoSgIlol2Bfu7
0VjNlLEoh6af9sYeLmNfe9mtZytAFeIclYblghXkaFMu99mIE5/+1wY8Xsusvy9j
QEawWenxzNEWoMBaHLQqXoo6gZYJ3/xUZKivKJNUOuo/xNYV0HEJn84epdq8h+iW
LqWaC5WQ5rcACvRhbef2PBsocYPFHqcezBvhkuU1YQVOBP5Yf4bu3VqQOsQ9+xOR
S+qZxy63MYsFGHai3tghaFc5MlzyuUrXa64KpCIQ/kIClRNi1UvFYyOsx2WysgVI
eOOBzqId4ZPgIcTMzWu2
=JUn2
-----END PGP SIGNATURE-----

--OIdjbDHu73uSig5EAG7pPhOC3jFrBLtvl--
