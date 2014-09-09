From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 1/3] can: c_can_platform: Fix c_can_hw_raminit_ti()
 and add timeout
Date: Tue, 09 Sep 2014 16:34:05 +0200
Message-ID: <540F0FDD.60201@pengutronix.de>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com> <1410273070-22485-2-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="1fWI2LwfFTB6GbcLT2Vn6xV0OBUvvPcv6"
Cc: tony@atomide.com, tglx@linutronix.de, mugunthanvnm@ti.com,
	george.cherian@ti.com, balbi@ti.com, nsekhar@ti.com, nm@ti.com,
	sergei.shtylyov@cogentembedded.com, linux-omap@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, wg@grandegger.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1410273070-22485-2-git-send-email-rogerq@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--1fWI2LwfFTB6GbcLT2Vn6xV0OBUvvPcv6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2014 04:31 PM, Roger Quadros wrote:
> Pass the correct 'mask' and 'value' bits to c_can_hw_raminit_wait_ti().=

> They seem to have been swapped in the usage instances.

Can you split this fix into a seperate patch, please.

> TI's RAMINIT DONE mechanism is buggy and may not always be
> set after the START bit is set. So add a timeout mechanism to
> c_can_hw_raminit_wait_ti().

What should happen if the timeout occurs?

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--1fWI2LwfFTB6GbcLT2Vn6xV0OBUvvPcv6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlQPD90ACgkQjTAFq1RaXHMiUQCeI8uNJSIRtBFoAbFHZn8ynNcm
G/wAni3NaZ0YoQH99Ui+ZrIiUNxFved8
=C3BM
-----END PGP SIGNATURE-----

--1fWI2LwfFTB6GbcLT2Vn6xV0OBUvvPcv6--
