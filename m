From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] can: xilinx CAN controller support.
Date: Fri, 14 Feb 2014 10:16:20 +0100
Message-ID: <52FDDEE4.9060902@pengutronix.de>
References: <\> <0dc128ac-e5cd-47bd-9ab1-3a545c3e2043@CO9EHSMHS012.ehs.local> <52FD1B16.6020600@pengutronix.de> <52FDD9FE.8040908@monstr.eu> <52FDDC24.8070805@pengutronix.de> <52FDDE30.8020405@monstr.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="4UQTvQD5XCcNvDjoJ5wUCVPt9UOHhh50p"
Cc: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com,
	grant.likely@linaro.org, robh+dt@kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: monstr@monstr.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52FDDE30.8020405@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--4UQTvQD5XCcNvDjoJ5wUCVPt9UOHhh50p
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/14/2014 10:13 AM, Michal Simek wrote:
>>> That's not entirely truth. If you look at Microblaze then you will se=
e
>>> that Microblaze can be BE and LE.
>>> There is just missing endian detection which we will add to the next =
version.
>>
>> As far as I know the endianess of the kernel is fixed and known during=

>> compile time. Correct me if I'm wrong. So there is no need for a runti=
me
>> detection of the endianess and so no need for {read,write}_reg functio=
n
>> pointers.
>=20
> Endianess of the kernel is fixed and know during compile time
> but what it is not fixed is endianess of that IP at compile time.
>=20
> On fpga you can use bridges, partial reconfiguration, etc where
> the only solution which is run-time endian detection via registers.
>=20
> For example: drivers/block/xsysace.c, drivers/spi/spi-xilinx.c, etc

Okay, now I get it. You can make it more complex then it used to be :D

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--4UQTvQD5XCcNvDjoJ5wUCVPt9UOHhh50p
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlL93uQACgkQjTAFq1RaXHM5nwCggs0uUUYPbJ19vDd7HKsWoy6/
E5QAn1RTNztWr/e94iUSTdzPUSw+Th9Y
=v8+D
-----END PGP SIGNATURE-----

--4UQTvQD5XCcNvDjoJ5wUCVPt9UOHhh50p--
