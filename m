From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 00/35] constify net usb_device_id
Date: Thu, 10 Aug 2017 13:02:02 +0200
Message-ID: <289a61a2-7f2a-2da7-450d-55b9a5f3bc19@pengutronix.de>
References: <1502207730-11404-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="sSbUrqq1NorDHiXk5kunRdfcfPoO0UaTe"
Cc: linux-kernel@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>, kvalo@codeaurora.org,
        wg@grandegger.com, linux-can@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1502207730-11404-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--sSbUrqq1NorDHiXk5kunRdfcfPoO0UaTe
Content-Type: multipart/mixed; boundary="Vp1oRd3GKk49F78XNSUBHvsPJhGi7H6lr";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Arvind Yadav <arvind.yadav.cs@gmail.com>, kvalo@codeaurora.org,
 wg@grandegger.com, linux-can@vger.kernel.org, netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Message-ID: <289a61a2-7f2a-2da7-450d-55b9a5f3bc19@pengutronix.de>
Subject: Re: [PATCH 00/35] constify net usb_device_id
References: <1502207730-11404-1-git-send-email-arvind.yadav.cs@gmail.com>
In-Reply-To: <1502207730-11404-1-git-send-email-arvind.yadav.cs@gmail.com>

--Vp1oRd3GKk49F78XNSUBHvsPJhGi7H6lr
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: quoted-printable

On 08/08/2017 05:55 PM, Arvind Yadav wrote:
> usb_device_id are not supposed to change at runtime. All functions
> working with usb_device_id provided by <linux/usb.h> work with
> const usb_device_id. So mark the non-const structs as const.
>=20
> [PATCH 10/35] :Fix checkpatch.pl error.
> ERROR: space prohibited before open square bracket '['.
>=20
> Arvind Yadav (35):
>   [PATCH 01/35] can: ems_usb: constify usb_device_id
>   [PATCH 02/35] can: esd_usb2: constify usb_device_id
>   [PATCH 03/35] can: peak_usb: constify usb_device_id

For the CAN patches:

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Vp1oRd3GKk49F78XNSUBHvsPJhGi7H6lr--

--sSbUrqq1NorDHiXk5kunRdfcfPoO0UaTe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlmMPSoACgkQHv7KIOw4
HPbEowgAlgZXUop04sEDHYlupFXQHqlbnfdCV6oQZV+WC94pFAXrLxvksAtZleNE
bjPcCdP71Rhi2J/4Y/SUtJ4X8rfe/4Hwxs5tqhS9JYWAYrvfPV7FVZuh41d59au4
0eGOr1RWhu3w8iCQU4aUrbx5ycimwVPiXZ9wcczYecDDGRtbRYtve/xkZLH3g46y
vk/DkgIUHpDsy9IS7sPNlmhJQKaLc8qByVHTfPG+mqEFKCWNgdjgUW+K2mSk1Xzw
npsY9fxcriB4yWFLy/lvxny894SFcbaoTfnU9qxro5L5UTNx+6ZLT1NZqbu0LoJd
RWTyzzNvozKhEeQNyELLhLrJgI2dmA==
=LYa6
-----END PGP SIGNATURE-----

--sSbUrqq1NorDHiXk5kunRdfcfPoO0UaTe--
