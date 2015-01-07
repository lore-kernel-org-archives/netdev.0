From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4] can: Convert to runtime_pm
Date: Wed, 07 Jan 2015 17:36:08 +0100
Message-ID: <54AD6078.80506@pengutronix.de>
References: <58f37b6fd9104ce185c413c473fe047b@BY2FFO11FD050.protection.gbl> <54AD267C.4060004@pengutronix.de> <a868331b44ce4b2a80b572399530f1f9@BN1BFFO11FD043.protection.gbl> <54AD5F13.1020107@pengutronix.de> <1d3216d75e9d494fb68ce9a3b24e7ca3@BL2FFO11FD017.protection.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="R95cRwpVO2ie2gjCTulG8FpOL2W3F089U"
Cc: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com,
	grant.likely@linaro.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: =?UTF-8?B?U8O2cmVuIEJyaW5rbWFubg==?= <soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1d3216d75e9d494fb68ce9a3b24e7ca3@BL2FFO11FD017.protection.gbl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--R95cRwpVO2ie2gjCTulG8FpOL2W3F089U
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/07/2015 05:32 PM, S=C3=B6ren Brinkmann wrote:
> On Wed, 2015-01-07 at 05:30PM +0100, Marc Kleine-Budde wrote:
>> On 01/07/2015 04:58 PM, S=C3=B6ren Brinkmann wrote:
>>>> I think you have to convert the _remove() function, too. Have a look=
 at
>>>> the gpio-zynq.c driver:
>>>>
>>>>> static int zynq_gpio_remove(struct platform_device *pdev)
>>>>> {
>>>>> 	struct zynq_gpio *gpio =3D platform_get_drvdata(pdev);
>>>>>
>>>>> 	pm_runtime_get_sync(&pdev->dev);
>>>>
>>>> However I don't understand why the get_sync() is here. Maybe S=C3=B6=
ren can help?
>>>
>>> IIRC, the concern was that the remove function may be called while th=
e device is
>>> runtime suspended. Hence the remove function needs to resume the devi=
ce since the
>>> remove function may access the HW.
>>
>> What about the corresponding runtime_put()? Would some counter be
>> unbalanced upon device removal?
>=20
> Aren't those counters destroyed with module unloading?

I don't know.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--R95cRwpVO2ie2gjCTulG8FpOL2W3F089U
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUrWB4AAoJECte4hHFiupU90oP/RO4Afg8tuWj6Z4WpiVbiUuB
DzCdhK+otWYLqyPqVRkCezA5Q2Q8RfDSuQOTaqhzYljqv70h1/DFwWMmyeUfhc8X
067m+aXmgXJPD7G4Xr4K6/zgBqE1oI1zQmbBg57Ze2pRgkkZrNw5P/N7rncxnMvr
nFKKmuDmaDpOPz0Ap0R8tbwpiMchbAZcXJNJwum/3TRttDUPdMAK9Hq/EzZfZk4F
91jyKGaXew3sSskgr1HIEbIH8R/k1mFU5EZOh+xMuw5QFYQ+tak+N7lOEOPOYte9
+yvOS5/I58EqOwLFjZnOAMTffncPyU6iTota6NzXJClbGvUcpOKXV+IDW3a8CFt/
U6diBVRK9bU6uW25SEllc+OXvkOgHCCu3B0/oMCK/R8BaKgfnOzz7EISJB2vYce8
MvMDQqvFXkBkEVxdmv8HaBwAFTFUP5KmPIh4FfzFLLZ+LkjZZ/oZSe3PzvLxLBbj
amclgdCQApmGu59Cvi+wy+u74928Q3Ql2Q+jNCHtfWGf2Ao1MpDPyZ23cxMyOrrN
5PF/TgPXSyxrNtsQwRy8QkgO9i+eW3AQsixama/HoC2zOxvusqH3DuKij9soZDNa
kQ2i8HLDuZvD0FFOZVLMwl/oPTArQJzBfbKM8cmL5lHdwIdHXzp4x40VmDUYciX3
yK9pcttT976Jr5VSlXAa
=7KiB
-----END PGP SIGNATURE-----

--R95cRwpVO2ie2gjCTulG8FpOL2W3F089U--
