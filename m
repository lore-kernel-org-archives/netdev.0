From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: Enable xilinx driver for all ARCHs
Date: Mon, 09 Mar 2015 10:13:00 +0100
Message-ID: <54FD641C.7090607@pengutronix.de>
References: <4096fa4ceae72817d8e64d9a1da738038a5c864a.1425890926.git.michal.simek@xilinx.com> <54FD5EE1.6050402@pengutronix.de> <BY2FFO11FD001BD9CFD92C94214501BB8E21B0@BY2FFO11FD001.protection.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="nDuV4miBoqOicMiA2p19twlE9CnjPqBpU"
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, Jean Delvare <jdelvare@suse.de>
To: Michal Simek <michal.simek@xilinx.com>,
	linux-kernel@vger.kernel.org, monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:39544 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190AbbCIJNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 05:13:19 -0400
In-Reply-To: <BY2FFO11FD001BD9CFD92C94214501BB8E21B0@BY2FFO11FD001.protection.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--nDuV4miBoqOicMiA2p19twlE9CnjPqBpU
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/09/2015 09:58 AM, Michal Simek wrote:
> On 03/09/2015 09:50 AM, Marc Kleine-Budde wrote:
>> On 03/09/2015 09:48 AM, Michal Simek wrote:
>>> Remove Kconfig dependency and enable driver for
>>> all ARCHs.
>>>
>>> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
>>> Acked-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>
>>> ---
>>>
>>> Test for all archs done by Kbuild test robot without any problem.
>>> ---
>>>  drivers/net/can/Kconfig | 1 -
>>>  1 file changed, 1 deletion(-)
>>>
>>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
>>> index 98d73aab52fe..f690c3fb3088 100644
>>> --- a/drivers/net/can/Kconfig
>>> +++ b/drivers/net/can/Kconfig
>>> @@ -131,7 +131,6 @@ config CAN_RCAR
>>> =20
>>>  config CAN_XILINXCAN
>>>  	tristate "Xilinx CAN"
>>> -	depends on ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST
>>
>> I think that's what COMPILE_TEST ist for?
>=20
> For compilation yes but not for enabling. Currently this driver
> can be also used on ARM64 that's why people suggesting directly
> to remove dependency on arch and then COMPILE_TEST can be removed
> too.

In the past (May 2014) I had people complaining that certain ARM SoC
specific drivers are enabled on ARM in general, not just on that SoC. As
I'm not following arm64 in detail, has the notion of using depends on
ARCH changes since then?

> Or do you want me to change description to mention that this is for
> ARM64 enabling?

Given this is consensus, a remark to ARM64 would be appreciated. :)

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--nDuV4miBoqOicMiA2p19twlE9CnjPqBpU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJU/WQfAAoJECte4hHFiupUxj0QAJcQmjNEPR3m02juELrXJ8xq
8fABiSWRkhOgz86va5c+aJBuK0Z2/bQnz8wEKMK+mids+tRY83L5PFgX9+qu1D0j
cW1wqTm7ld8Ks8ipJ/R4kzqGRj8otCV6qmebe3PXnzhvMUAfJqRTyMSmfRjE7yF3
kNy2DRiTO09YQGqUZ3dbpx0Is306oorkNcB3cScA5GbXhwL+TNBS3n/TlQLza+bn
CYZXqThsy4WoIe1rIJ6mLwIX8Qqws2jEgDqSIeS98zmnth9jyJzvD90Z42Epai9i
owHtZlU08bsjlfYOamEna6jpgZ07oPJPDIw788n+kOiqN17TJILXL2bW127tgbkj
63hyXf5v0Ldx79pNlkEkIScJ53Exb3MqJ4EmwDQwFeuDmJzx7JEF2OJFuarci4cK
pJCJHTLV+5CJRhBfc3wjivJ25OTTtPDjki+puIWIyXuEPZ91CWidN+jTvracDIw2
BIFVGhCfIQ778Ve1UDvsxUWjzPcD73cQw/oXZrf76JrzAWTac226G1BS7yByJAFB
XCcS3SakaM/uRcutbQmrE6kQV22WQsfD+IPg9F9yL2bhIXhWcsTDaqtBwc5lvrm+
+rRa+nWds3w94pqryr8ZADUwH94exMLk60qrkHNbUca3sH/l1ExDBzK79wQhH5/i
WsRZDk3EdpLPt/pVD7BW
=RwcL
-----END PGP SIGNATURE-----

--nDuV4miBoqOicMiA2p19twlE9CnjPqBpU--
