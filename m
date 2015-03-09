From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH] net: can: Enable xilinx driver for all ARCHs
Date: Mon, 9 Mar 2015 09:58:55 +0100
Message-ID: <BY2FFO11FD001BD9CFD92C94214501BB8E21B0@BY2FFO11FD001.protection.gbl>
References: <4096fa4ceae72817d8e64d9a1da738038a5c864a.1425890926.git.michal.simek@xilinx.com>
 <54FD5EE1.6050402@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="36HKL5KPJep1Pa62mA6s5sWIsOKLntudx"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Michal Simek <michal.simek@xilinx.com>,
	<linux-kernel@vger.kernel.org>, <monstr@monstr.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54FD5EE1.6050402@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--36HKL5KPJep1Pa62mA6s5sWIsOKLntudx
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/09/2015 09:50 AM, Marc Kleine-Budde wrote:
> On 03/09/2015 09:48 AM, Michal Simek wrote:
>> Remove Kconfig dependency and enable driver for
>> all ARCHs.
>>
>> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
>> Acked-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>
>> ---
>>
>> Test for all archs done by Kbuild test robot without any problem.
>> ---
>>  drivers/net/can/Kconfig | 1 -
>>  1 file changed, 1 deletion(-)
>>
>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
>> index 98d73aab52fe..f690c3fb3088 100644
>> --- a/drivers/net/can/Kconfig
>> +++ b/drivers/net/can/Kconfig
>> @@ -131,7 +131,6 @@ config CAN_RCAR
>> =20
>>  config CAN_XILINXCAN
>>  	tristate "Xilinx CAN"
>> -	depends on ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST
>=20
> I think that's what COMPILE_TEST ist for?

For compilation yes but not for enabling. Currently this driver
can be also used on ARM64 that's why people suggesting directly
to remove dependency on arch and then COMPILE_TEST can be removed
too.
Or do you want me to change description to mention that this is for
ARM64 enabling?

Thanks,
Michal



--36HKL5KPJep1Pa62mA6s5sWIsOKLntudx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAlT9YNIACgkQykllyylKDCGDYwCeK0s3xOTy5+fqpCN01AN8q/iD
NrMAoJRxRqsn70AcEcrXQ+1nybPLhe/o
=JktT
-----END PGP SIGNATURE-----

--36HKL5KPJep1Pa62mA6s5sWIsOKLntudx--
