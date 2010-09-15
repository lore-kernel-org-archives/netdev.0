From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Wed, 15 Sep 2010 14:04:13 +0200
Message-ID: <4C90B63D.9030201@pengutronix.de>
References: <4C61EDE5.4030505@dsn.okisemi.com>	<4C629FE5.6000204@pengutronix.de>	<005f01cb533e$5c21d530$66f8800a@maildom.okisemi.com>	<4C8E1918.5000007@pengutronix.de>	<003a01cb53a6$4ca724d0$66f8800a@maildom.okisemi.com>	<4C9078D3.50300@grandegger.com> <4C909518.5010309@hartkopp.net> <4C90A60E.5040900@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA6B7827F61A3863B0D15CE72"
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	andrew.chih.howe.khor@intel.com, socketcan-core@lists.berlios.de,
	qi.wang@intel.com, netdev@vger.kernel.org, gregkh@suse.de,
	yong.y.wang@intel.com, Masayuki Ohtake <masa-korg@dsn.okisemi.com>,
	Morinaga <morinaga526@dsn.okisemi.com>, meego-dev@meego.com,
	arjan@linux.intel.com
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:43212 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492Ab0IOME0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 08:04:26 -0400
In-Reply-To: <4C90A60E.5040900@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA6B7827F61A3863B0D15CE72
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 09/15/2010 12:55 PM, Wolfgang Grandegger wrote:
>> Just a remark:
>>
>> During the IDF the informations about the Topcliff Controller Hub have=
 been
>> reworked, so that some of the documentation became available for the p=
ublic:
>>
>> http://edc.intel.com/Platforms/Atom-E6xx/#hardware
>>
>> Especially the Datasheet for the Platform Controller Hub EG20T can be =
found:
>>
>> http://download.intel.com/embedded/chipsets/datasheet/324211.pdf
>>
>> In chapter 13 there are some details about the CAN controller.
>=20
> Ah, thanks for the link. The CAN controller seems then to be similar to=

> the OKI MSM9225B.

According to the datasheet for the msm9225 I found, the chip has got an
8 bit interface (mmap'ed or spi). The Intel is 32 bit based (most, maybe
all, upper 16 bit are marked as reserverd).

cheers, Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigA6B7827F61A3863B0D15CE72
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkyQtkEACgkQjTAFq1RaXHNDkACfe2QLOU2W8I4LY5TxuNVcO49d
WDcAn2Dpm9PkmeLDZR5j3PHeZmD8o3qr
=rEDf
-----END PGP SIGNATURE-----

--------------enigA6B7827F61A3863B0D15CE72--
