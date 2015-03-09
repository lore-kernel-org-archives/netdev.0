From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: Enable xilinx driver for all ARCHs
Date: Mon, 09 Mar 2015 14:55:46 +0100
Message-ID: <54FDA662.8020801@pengutronix.de>
References: <4096fa4ceae72817d8e64d9a1da738038a5c864a.1425890926.git.michal.simek@xilinx.com>	 <54FD5EE1.6050402@pengutronix.de>	 <BY2FFO11FD001BD9CFD92C94214501BB8E21B0@BY2FFO11FD001.protection.gbl>	 <54FD641C.7090607@pengutronix.de>	 <BY2FFO11FD0060B11FE9C9305D5DFD12BE21B0@BY2FFO11FD006.protection.gbl>	 <54FD6E42.6070206@pengutronix.de> <1425909239.23920.60.camel@chaos.site>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="bFXWxidamuOgLi6tf6vEKbMdFOasBWsN5"
Cc: Michal Simek <michal.simek@xilinx.com>,
	linux-kernel@vger.kernel.org, monstr@monstr.eu,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Jean Delvare <jdelvare@suse.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1425909239.23920.60.camel@chaos.site>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--bFXWxidamuOgLi6tf6vEKbMdFOasBWsN5
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/09/2015 02:53 PM, Jean Delvare wrote:
> Le Monday 09 March 2015 =C3=A0 10:56 +0100, Marc Kleine-Budde a =C3=A9c=
rit :
>> On 03/09/2015 10:52 AM, Michal Simek wrote:
>>> On 03/09/2015 10:13 AM, Marc Kleine-Budde wrote:
>>>> On 03/09/2015 09:58 AM, Michal Simek wrote:
>>>>> On 03/09/2015 09:50 AM, Marc Kleine-Budde wrote:
>>>>>> On 03/09/2015 09:48 AM, Michal Simek wrote:
>>>>>>> Remove Kconfig dependency and enable driver for
>>>>>>> all ARCHs.
>>>>>>>
>>>>>>> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
>>>>>>> Acked-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>
>>>>>>> ---
>>>>>>>
>>>>>>> Test for all archs done by Kbuild test robot without any problem.=

>>>>>>> ---
>>>>>>>  drivers/net/can/Kconfig | 1 -
>>>>>>>  1 file changed, 1 deletion(-)
>>>>>>>
>>>>>>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
>>>>>>> index 98d73aab52fe..f690c3fb3088 100644
>>>>>>> --- a/drivers/net/can/Kconfig
>>>>>>> +++ b/drivers/net/can/Kconfig
>>>>>>> @@ -131,7 +131,6 @@ config CAN_RCAR
>>>>>>> =20
>>>>>>>  config CAN_XILINXCAN
>>>>>>>  	tristate "Xilinx CAN"
>>>>>>> -	depends on ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST
>>>>>>
>>>>>> I think that's what COMPILE_TEST ist for?
>>>>>
>>>>> For compilation yes but not for enabling. Currently this driver
>>>>> can be also used on ARM64 that's why people suggesting directly
>>>>> to remove dependency on arch and then COMPILE_TEST can be removed
>>>>> too.
>>>>
>>>> In the past (May 2014) I had people complaining that certain ARM SoC=

>>>> specific drivers are enabled on ARM in general, not just on that SoC=
=2E As
>>>> I'm not following arm64 in detail, has the notion of using depends o=
n
>>>> ARCH changes since then?
>>>>
>>>>> Or do you want me to change description to mention that this is for=

>>>>> ARM64 enabling?
>>>>
>>>> Given this is consensus, a remark to ARM64 would be appreciated. :)
>>>
>>> David has applied this patch which is in general just the same as thi=
s one.
>>>
>>> (linux-next) Remove architecture dependency
>>> 28811a8c00fe0d899b8a544421f3b4947425d5e8
>>>
>>> Mark Brown has suggested to do so for spi and don't check architectur=
e at
>>> all.
>>> I have also sent similar patch for watchdog driver too.
>>>
>>> I think it is up to you if you want to add ARM64 to Kconfig or just r=
emove
>>> that arch dependencies.
>>> To be honest my goal is to enable this driver for ARM64.
>>> Please tell me what way you prefer.
>>
>> I like the idea of removing the depends on ARCH completely. Jean, what=

>> do you think?
>=20
> Removing the dependency completely will let the option be displayed on
> systems where the driver is useless. I am in favor of having hardware
> dependencies on as many drivers as possible to avoid bothering the user=

> with irrelevant questions. The list of Kconfig entries has grown a lot
> over time!
>=20
> If the current dependency is too strict then I would suggest to extend
> it or to make it broader (depends on ARM || ARM64 || COMPILE_TEST would=

> be acceptable IMHO.) Dropping it completely only makes sense if the par=
t
> is used on so many systems that the dependency becomes too long or is a=

> pain to maintain.

Sounds reasonable. Michael, make it so.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--bFXWxidamuOgLi6tf6vEKbMdFOasBWsN5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJU/aZiAAoJECte4hHFiupUjD0QAKqfVjLJb+B83Sp3RXjJz1vG
0OO1G4XJTilHJxICEi7FoBinpmDouIe5xiuPUAJAMfGDz/UTcUAFFndwPUZm1zNU
1G5jASjTru2BhmKMiiRv+5hBHxT7P24xuQ4tfRS+NQYNUdSxv2ryxT0BmoufcdtS
ccFgV/0bRAWiSS0G1SUyetHR7R8wCxd6VbZ9++YYFS+nuExlAGWp9k6thjdWFqiV
VRLBMekBGrnEo7IaQwSRbmidKGRGT1KSpDos772oSSb6RIcwawPb3r+F+pP0Rg3W
zVmkLN0sK5CL98YVnjYwQ8fy/vnjKwI+FPahbUJNufHlQ8EKvnl4rxD703NBkudU
XhkdRWkANcn5I8Mkpy4WXOrR45Y1fxosbmi+mxamibN2YSjXby9qzQllCsc8cYAN
vnb3LaEVDqhC5nvXq68SEEm35exG2YfqpXLQ/4RHQu1y+W9SZQIQ6mj3GcfNEKDu
/DPwyAAARFm4NKNIX3ThIT/p4j4j47H9EnxjmEMbnGi543i++drkR5CNP9wjK8BP
y6/Ug2wcWLViuGGMlvBVU0HQhg/rECTE0xqkCEhqPs/6C3YgbEoBNtUNbgWYRWx2
SsDcxibUcfq+Bh8Ly0/dCCzp007nPRchcPWZwbu93zamGtG20pZhncJNqGmUNttE
JZ/8wduUUHG0NaaWrISH
=WEq0
-----END PGP SIGNATURE-----

--bFXWxidamuOgLi6tf6vEKbMdFOasBWsN5--
