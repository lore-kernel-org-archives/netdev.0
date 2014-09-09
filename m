From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 05/13] ARM: dts: DRA7: Add DCAN nodes
Date: Tue, 09 Sep 2014 10:34:54 +0200
Message-ID: <540EBBAE.9030300@pengutronix.de>
References: <1410185442-907-1-git-send-email-rogerq@ti.com> <1410185442-907-6-git-send-email-rogerq@ti.com> <540DDBE0.5090004@cogentembedded.com> <540EBABA.9090009@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="sTWmcJ4ggJCqOkf42saWRG7EWRgGV6Gxo"
Cc: tglx@linutronix.de, linux-omap@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com
To: Roger Quadros <rogerq@ti.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	wg@grandegger.com, tony@atomide.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <540EBABA.9090009@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--sTWmcJ4ggJCqOkf42saWRG7EWRgGV6Gxo
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2014 10:30 AM, Roger Quadros wrote:
>>> +            compatible =3D "bosch,d_can";
>>> +            ti,hwmods =3D "dcan1";
>>> +            reg =3D <0x4ae3c000 0x2000>,
>>> +                  <0x558 0x4>; /* index to RAMINIT reg within syscon=
 */
>>> +            raminit-syscon =3D <&dra7_ctrl_core>;
>>> +            raminit-start-bit =3D <3>;
>>> +            raminit-done-bit =3D <1>;
>>> +            raminit-pulse;
>>
>>    Hm, aren't the above 4 properties vendor specific? If so, they shou=
ld start with a vendor prefix and comma.
>=20
> At least for now I don't know about any other platform other than TI us=
ing a RAMINIT register outside the
> CAN register space. However the mechanism is generic enough and not lim=
ited to TI platforms.
>=20
> I don't mind vendor prefix or not, but would like to hear the opinion o=
f the CAN maintainers as to what they would prefer.

I don't know of any c_can/d_can implementation outside of TI that
implements the raminit outside of the register space. So a "ti," prefix
seems appropriate.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--sTWmcJ4ggJCqOkf42saWRG7EWRgGV6Gxo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlQOu64ACgkQjTAFq1RaXHPmaACfYpxzNeWEcShhwf7DDSL5x7dH
JM4AnivEqX/Uv5oFb3IE8FtPHgahsOV3
=QoET
-----END PGP SIGNATURE-----

--sTWmcJ4ggJCqOkf42saWRG7EWRgGV6Gxo--
