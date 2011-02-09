From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v6 1/1] can: c_can: Added support for Bosch
	C_CAN	controller
Date: Wed, 09 Feb 2011 11:46:55 +0100
Message-ID: <4D52709F.1020700@pengutronix.de>
References: <1297227821-18021-1-git-send-email-bhupesh.sharma@st.com>
	<4D525DF8.6050409@pengutronix.de> <4D526F5A.6030706@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0728554536784441054=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D526F5A.6030706-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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
--===============0728554536784441054==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig35254954A2438BDDAD411EDF"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig35254954A2438BDDAD411EDF
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 02/09/2011 11:41 AM, Wolfgang Grandegger wrote:
> Hi Marc,
>=20
> On 02/09/2011 10:27 AM, Marc Kleine-Budde wrote:
>> On 02/09/2011 06:03 AM, Bhupesh Sharma wrote:
>>> +	if (flags & IF_ARB_TRANSMIT)
>>> +		frame->can_id |=3D CAN_RTR_FLAG;
>>
>> Can you please only copy the data to the frame if the rtr flag isn't
>> set. Not all driver do this yet, but we've agreed to do so.
>=20
> Yes, I remember the patch
>=20
> [PATCH v2 0/9] can: don't copy data to rx'ed RTR frames
>=20
> What happend with it?

*g* - I didn't compile tested all drivers, and David found an error. I'm
busy right now but I've requested a timeslot for it.

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig35254954A2438BDDAD411EDF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk1ScKIACgkQjTAFq1RaXHNO7ACgkD1KYYFh4p9228v/ObeDkDh5
MjsAnigYw/bslRIsUtMXZoxoKNkZz/mg
=G6hO
-----END PGP SIGNATURE-----

--------------enig35254954A2438BDDAD411EDF--

--===============0728554536784441054==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============0728554536784441054==--
