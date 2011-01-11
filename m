From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v3 1/1] can: c_can: Added support for
	Bosch C_CAN controller
Date: Tue, 11 Jan 2011 23:38:43 +0100
Message-ID: <20110111223843.GB18762@pengutronix.de>
References: <1294135195-9448-1-git-send-email-bhupesh.sharma@st.com>
	<4D2829C5.5020206@grandegger.com>
	<D5ECB3C7A6F99444980976A8C6D896384DEAFA2D9D@EAPEX1MAIL1.st.com>
	<4D2C14FE.7080903@grandegger.com> <4D2CA0AA.6080505@grandegger.com>
	<4D2CD34B.8000609@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7823956950763027193=="
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D2CD34B.8000609-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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


--===============7823956950763027193==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="eAbsdosE1cNLO4uF"
Content-Disposition: inline


--eAbsdosE1cNLO4uF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 11, 2011 at 11:01:47PM +0100, Marc Kleine-Budde wrote:
> On 01/11/2011 07:25 PM, Wolfgang Grandegger wrote:
>=20
> [...]
>=20
> > I was told that Bosch's page for the C_CAN is here:
> >=20
> >  http://www.semiconductors.bosch.de/en/ipmodules/can/canipmodules/c_can=
/c_can.asp
> >=20
> > There it's also written for what bus interfaces the C_CAN is available =
for, e.g.:
> >=20
> >   "The ASIC version is delivered with the AMBA APB bus interface from A=
RM."
>=20
> On ARM we also have the AMBA bus abstraction in Linux, but I've never
> worked with it. IIRC Wolfram (Cc'ed) has recently touched it.

For a programmer, it feels very much like a platform-bus (you can even use
amba-devices on a platform_bus); it has the advantage of some identification
registers at the end of the address-space. The rest is more about how to
connect the core to the SoC. Does that help? I don't know what the actual
question is :)

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--eAbsdosE1cNLO4uF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAk0s2/MACgkQD27XaX1/VRvAkwCgzHRhOzqlRMvzLF6ndmp6R9RQ
PUsAoMkVqvS6IcV70F9yxHLBr45qBeS3
=qCUJ
-----END PGP SIGNATURE-----

--eAbsdosE1cNLO4uF--

--===============7823956950763027193==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============7823956950763027193==--
