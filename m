From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH v5] can: xilinx CAN controller support.
Date: Wed, 12 Mar 2014 11:01:44 +0100
Message-ID: <53203088.2070605@monstr.eu>
References: <5254bfec-c6fd-4681-a34d-706d51e60fbb@VA3EHSMHS004.ehs.local> <531DD2C4.5060109@pengutronix.de> <f1e2f08f-05fc-40d3-8437-4c6817d631cb@AM1EHSMHS010.ehs.local> <531F0636.4050608@pengutronix.de>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="ldFvFjGoGEJrjV5t1gFhQXOG5BcuKQW8j"
Cc: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	Michal Simek <michals@xilinx.com>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"fengguang.wu@intel.com" <fengguang.wu@intel.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <531F0636.4050608@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ldFvFjGoGEJrjV5t1gFhQXOG5BcuKQW8j
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 03/11/2014 01:48 PM, Marc Kleine-Budde wrote:
> On 03/11/2014 01:34 PM, Appana Durga Kedareswara Rao wrote:
>=20
>>>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig index=

>>>> 9e7d95d..b180239 100644
>>>> --- a/drivers/net/can/Kconfig
>>>> +++ b/drivers/net/can/Kconfig
>>>> @@ -125,6 +125,13 @@ config CAN_GRCAN
>>>>       endian syntheses of the cores would need some modifications on=

>>>>       the hardware level to work.
>>>>
>>>> +config CAN_XILINXCAN
>>>> +   tristate "Xilinx CAN"
>>>> +   depends on ARCH_ZYNQ || MICROBLAZE
>>>
>>> Is Zynq multiarch already?
>> Discussions are going on this
>> So the final thing that Fengguang ( fengguang.wu@intel.com)
>> Proposed is
>>         config CAN_XILINX
>>         tristate "Xilinx CAN"
>>         depends on ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST
>>         depends on COMMON_CLK && HAS_MMIO  # whatever you need for oth=
er architectures
>=20
>> Are you Ok for this?
>=20
> You have to fill the 2nd depends on with some sane values, though.

This should be that one
config CAN_XILINX
         tristate "Xilinx CAN"
         depends on ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST
         depends on COMMON_CLK && HAS_IOMEM


Is there any driver which is in CAN which not use MMIO accesses?
If not, maybe we should just add dependency to

Thanks,
Michal



--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--ldFvFjGoGEJrjV5t1gFhQXOG5BcuKQW8j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlMgMIgACgkQykllyylKDCEE2QCgjus6aeMcpmM2WD1fQEEEd1/g
IWMAn2/4zK08QsMZT8fws8gj4gUZQCdM
=Mwlw
-----END PGP SIGNATURE-----

--ldFvFjGoGEJrjV5t1gFhQXOG5BcuKQW8j--
