From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Tue, 15 Mar 2016 13:51:51 +0100
Message-ID: <56E80567.9060201@pengutronix.de>
References: <1457019515-21158-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1458035294-8150-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="6nomFkabhXg7Xua0Wkbm7e13uQQ3O9l37"
Cc: linux-renesas-soc@vger.kernel.org, devicetree@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, geert+renesas@glider.be,
	chris.paterson2@renesas.com
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
	wg@grandegger.com, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, corbet@lwn.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:59673 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932782AbcCOMwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 08:52:20 -0400
In-Reply-To: <1458035294-8150-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--6nomFkabhXg7Xua0Wkbm7e13uQQ3O9l37
Content-Type: multipart/mixed; boundary="tVEFGSCu3uInSe5LrCKVaiDJhlpLsPSna"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
 wg@grandegger.com, robh+dt@kernel.org, pawel.moll@arm.com,
 mark.rutland@arm.com, ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
 corbet@lwn.net
Cc: linux-renesas-soc@vger.kernel.org, devicetree@vger.kernel.org,
 linux-can@vger.kernel.org, netdev@vger.kernel.org,
 linux-doc@vger.kernel.org, geert+renesas@glider.be,
 chris.paterson2@renesas.com
Message-ID: <56E80567.9060201@pengutronix.de>
Subject: Re: [PATCH v3] can: rcar_canfd: Add Renesas R-Car CAN FD driver
References: <1457019515-21158-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1458035294-8150-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
In-Reply-To: <1458035294-8150-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>

--tVEFGSCu3uInSe5LrCKVaiDJhlpLsPSna
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/15/2016 10:48 AM, Ramesh Shanmugasundaram wrote:
> This patch adds support for the CAN FD controller found in Renesas R-Ca=
r
> SoCs. The controller operates in CAN FD only mode by default.
>=20
> CAN FD mode supports both Classical CAN & CAN FD frame formats. The
> controller supports ISO 11898-1:2015 CAN FD format only.
>=20
> This controller supports two channels and the driver can enable either
> or both of the channels.
>=20
> Driver uses Rx FIFOs (one per channel) for reception & Common FIFOs (on=
e
> per channel) for transmission. Rx filter rules are configured to the
> minimum (one per channel) and it accepts Standard, Extended, Data &
> Remote Frame combinations.
>=20
> Note: There are few documentation errors in R-Car Gen3 Hardware User
> Manual v0.5E with respect to CAN FD controller. They are listed below:
>=20
> 1. CAN FD interrupt numbers 29 & 30 are listed as per channel
> interrupts. However, they are common to both channels (i.e.) they are
> global and channel interrupts respectively.
>=20
> 2. CANFD clock is derived from PLL1. This is not documented.
>=20
> 3. CANFD clock is further divided by (1/2) within the CAN FD controller=
=2E
> This is not documented.
>=20
> 4. The minimum value of NTSEG1 in RSCFDnCFDCmNCFG register is 2 Tq. It
> is specified 4 Tq in the manual.
>=20
> 5. The maximum number of message RAM area the controller can use is 358=
4
> bytes. It is specified 10752 bytes in the manual.
>=20
> Signed-off-by: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.rene=
sas.com>
> ---
> Hi All,
>=20
>    Thanks for the review comments.
>=20
>    This updated patch is based on linux-can-next tag (linux-can-next-fo=
r-4.6-20160310).
>=20
>    This patch depends on
>=20
>    [RFC] [PATCH v3] can: fix handling of unmodifiable configuration opt=
ions
>    (http://comments.gmane.org/gmane.linux.can/9126)
>=20
> Changes since v2:
> 	* Rebased to latest tag (linux-can-next-for-4.6-20160310)
> 	* Cleaned up leftover debugfs code (Thanks Oliver H)
> 	* Revised devicetree documentation text (as suggested by Rob H)
> 	  (https://www.mail-archive.com/linux-renesas-soc@vger.kernel.org/msg0=
1597.html)
> 	* Used new can subsystem api to set static configuration & removed che=
ck in rcar_canfd_start (as suggested by Oliver H)
> 	  (Refer: http://comments.gmane.org/gmane.linux.can/9126 &
> 	   https://www.mail-archive.com/linux-renesas-soc@vger.kernel.org/msg0=
1867.html)
> 	* Clubbed Renesas controller drivers to driver/net/can/rcar dir (as su=
ggested by Oliver H)

Please make moving of the existing drivers a separate patch.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--tVEFGSCu3uInSe5LrCKVaiDJhlpLsPSna--

--6nomFkabhXg7Xua0Wkbm7e13uQQ3O9l37
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJW6AVnAAoJED07qiWsqSVqRZAH/2Sgg5ZB3lVEHw6niY8B5p5S
OaUlvXm2LvGM55+hFnyswDdIYRkHRhpt6ww7b1FscdJISPXyac4QpUz1HCYgEiV1
vkETBGfVcza4XCgGwN9rSXPwJdLpS5Mgaf6lkCewdZ6Wv1RKXrA72pheOrkusu79
EWoz1wkJ7doJvIyaOJiI6ehME1PM/VZjXhxjG3ZSWnIYZVsPafmo6XMs/yfyEamX
0Yb4o6ucKxXQuR7vKClEx/1zrYvX4q9OAjSafW63vu9EoU40N1tnBNbW66s+GlwA
7nn23dHmsZzr5TTdmUTXJYStFMnHhWQH0NLo/SboCYgyaCFhRf0/ocoAY25UlfA=
=TcTX
-----END PGP SIGNATURE-----

--6nomFkabhXg7Xua0Wkbm7e13uQQ3O9l37--
