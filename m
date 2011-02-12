From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v7 1/1] can: c_can: Added support for Bosch
	C_CAN	controller
Date: Sat, 12 Feb 2011 18:18:37 +0100
Message-ID: <4D56C0ED.1040201@pengutronix.de>
References: <1297419478-27667-1-git-send-email-bhupesh.sharma@st.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8563288315456681763=="
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1297419478-27667-1-git-send-email-bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============8563288315456681763==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig5F2349BE3C9360035CD89859"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig5F2349BE3C9360035CD89859
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 02/11/2011 11:17 AM, Bhupesh Sharma wrote:
> Bosch C_CAN controller is a full-CAN implementation which is compliant
> to CAN protocol version 2.0 part A and B. Bosch C_CAN user manual can b=
e
> obtained from:
> http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/
> c_can/users_manual_c_can.pdf
>=20
> This patch adds the support for this controller.
> The following are the design choices made while writing the controller
> driver:
> 1. Interface Register set IF1 has be used only in the current design.
> 2. Out of the 32 Message objects available, 16 are kept aside for RX
>    purposes and the rest for TX purposes.
> 3. NAPI implementation is such that both the TX and RX paths function
>    in polling mode.
>=20
> Signed-off-by: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>

Good work!

Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig5F2349BE3C9360035CD89859
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk1WwPAACgkQjTAFq1RaXHMVjQCgkK528zdxyv5DrUXkna0dvGeS
EWEAn3A8+vtSRfNAb/9+mHCwce+JK5mf
=QLtQ
-----END PGP SIGNATURE-----

--------------enig5F2349BE3C9360035CD89859--

--===============8563288315456681763==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============8563288315456681763==--
