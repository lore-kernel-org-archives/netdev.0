From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 0/5] can: sja1000: cleanups and new OF property
Date: Thu, 30 Jan 2014 16:36:43 +0100
Message-ID: <52EA718B.3090006@pengutronix.de>
References: <1391092168-21246-1-git-send-email-florian.vaussard@epfl.ch> <52EA6E31.2030604@pengutronix.de> <52EA6F6E.1010405@epfl.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="eONac84wvX5S60lABMBBko2O26aN63god"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: florian.vaussard@epfl.ch, Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52EA6F6E.1010405@epfl.ch>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--eONac84wvX5S60lABMBBko2O26aN63god
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/30/2014 04:27 PM, Florian Vaussard wrote:
> Hello,
>=20
> On 01/30/2014 04:22 PM, Marc Kleine-Budde wrote:
>> Hello Florian,
>>
>> On 01/30/2014 03:29 PM, Florian Vaussard wrote:
>>> The first part of this series performs serveral small cleanups
>>> (patches 1 to 3).
>>
>> Thanks for your contribution. I like patches 1 and 2.
>>
>>> The second part introduces the 'reg-io-width' binding (already used
>>> by some other drivers) to perform a similar job as what was done
>>> with IORESOURCE_MEM_XXBIT on the sja1000_platform. This is needed
>>> on my system to correctly take into account the aliasing of the
>>> address bus.
>>
>> And I appreciate the improvements for the of_platform driver. However
>> that driver was written back when it was not possible to have platform=

>> and of bindings in the same driver. So I'd like to see that the
>> of_platform driver gets merged into the platform driver.
>>
>=20
> Fine. Is an incremental patch on top of this series ok for you ?

I'd rather see patches 1 and 2 you have already posted, then probably a
modernization patch which converts the platform driver to use devm_ and
friends. Then a patch adding the existing of bindings [1]. This patch is
probably quite small if you prepare the driver in the modernization
patch properly. The last patch will add the new reg-io-width property.

Marc

[1] Maybe also deleting the existing of_platform driver, but I'm not sure=
=2E
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--eONac84wvX5S60lABMBBko2O26aN63god
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLqcYsACgkQjTAFq1RaXHOH5gCgkUexRggydqGHjsDZEx4CNQeF
hM4AnRWtt8lcC//yVSTxlGtFMV1g9Vmc
=7gYO
-----END PGP SIGNATURE-----

--eONac84wvX5S60lABMBBko2O26aN63god--
