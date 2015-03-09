From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH] net: can: Enable xilinx driver for all ARCHs
Date: Mon, 9 Mar 2015 10:52:28 +0100
Message-ID: <BY2FFO11FD0060B11FE9C9305D5DFD12BE21B0@BY2FFO11FD006.protection.gbl>
References: <4096fa4ceae72817d8e64d9a1da738038a5c864a.1425890926.git.michal.simek@xilinx.com>
 <54FD5EE1.6050402@pengutronix.de>
 <BY2FFO11FD001BD9CFD92C94214501BB8E21B0@BY2FFO11FD001.protection.gbl>
 <54FD641C.7090607@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="HBOjkljDiGF3K1I4MPWPaH7dVkIfWg9kO"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	Jean Delvare <jdelvare@suse.de>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Michal Simek <michal.simek@xilinx.com>,
	<linux-kernel@vger.kernel.org>, <monstr@monstr.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54FD641C.7090607@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--HBOjkljDiGF3K1I4MPWPaH7dVkIfWg9kO
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/09/2015 10:13 AM, Marc Kleine-Budde wrote:
> On 03/09/2015 09:58 AM, Michal Simek wrote:
>> On 03/09/2015 09:50 AM, Marc Kleine-Budde wrote:
>>> On 03/09/2015 09:48 AM, Michal Simek wrote:
>>>> Remove Kconfig dependency and enable driver for
>>>> all ARCHs.
>>>>
>>>> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
>>>> Acked-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>
>>>> ---
>>>>
>>>> Test for all archs done by Kbuild test robot without any problem.
>>>> ---
>>>>  drivers/net/can/Kconfig | 1 -
>>>>  1 file changed, 1 deletion(-)
>>>>
>>>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
>>>> index 98d73aab52fe..f690c3fb3088 100644
>>>> --- a/drivers/net/can/Kconfig
>>>> +++ b/drivers/net/can/Kconfig
>>>> @@ -131,7 +131,6 @@ config CAN_RCAR
>>>> =20
>>>>  config CAN_XILINXCAN
>>>>  	tristate "Xilinx CAN"
>>>> -	depends on ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST
>>>
>>> I think that's what COMPILE_TEST ist for?
>>
>> For compilation yes but not for enabling. Currently this driver
>> can be also used on ARM64 that's why people suggesting directly
>> to remove dependency on arch and then COMPILE_TEST can be removed
>> too.
>=20
> In the past (May 2014) I had people complaining that certain ARM SoC
> specific drivers are enabled on ARM in general, not just on that SoC. A=
s
> I'm not following arm64 in detail, has the notion of using depends on
> ARCH changes since then?
>=20
>> Or do you want me to change description to mention that this is for
>> ARM64 enabling?
>=20
> Given this is consensus, a remark to ARM64 would be appreciated. :)

David has applied this patch which is in general just the same as this on=
e.

(linux-next) Remove architecture dependency
28811a8c00fe0d899b8a544421f3b4947425d5e8

Mark Brown has suggested to do so for spi and don't check architecture at=

all.
I have also sent similar patch for watchdog driver too.

I think it is up to you if you want to add ARM64 to Kconfig or just remov=
e
that arch dependencies.
To be honest my goal is to enable this driver for ARM64.
Please tell me what way you prefer.

Thanks,
Michal




--HBOjkljDiGF3K1I4MPWPaH7dVkIfWg9kO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAlT9bVwACgkQykllyylKDCEiHQCfSvEhTJDREAPQQ/nf4Pv9Hp5Z
H0YAn1jOGsKXi4xZgO02SGaqR9SlhuTx
=rvKo
-----END PGP SIGNATURE-----

--HBOjkljDiGF3K1I4MPWPaH7dVkIfWg9kO--
