From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Sun, 19 Jun 2011 09:02:38 +0200
Message-ID: <20110619070238.GD1632@pengutronix.de>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
 <1308410354-21387-2-git-send-email-shawn.guo@linaro.org>
 <20110618161934.GH8195@ponder.secretlab.ca>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DrWhICOqskFTAXiy"
Cc: Shawn Guo <shawn.guo@linaro.org>, patches@linaro.org,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Jason Liu <jason.hui@linaro.org>, linux-kernel@vger.kernel.org,
	Jeremy Kerr <jeremy.kerr@canonical.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	linux-arm-kernel@lists.infradead.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:38625 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751766Ab1FSHCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 03:02:46 -0400
Content-Disposition: inline
In-Reply-To: <20110618161934.GH8195@ponder.secretlab.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--DrWhICOqskFTAXiy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jun 18, 2011 at 10:19:34AM -0600, Grant Likely wrote:
> On Sat, Jun 18, 2011 at 11:19:12PM +0800, Shawn Guo wrote:
> > It adds device tree data parsing support for imx tty/serial driver.
> >=20
> > Signed-off-by: Jeremy Kerr <jeremy.kerr@canonical.com>
> > Signed-off-by: Jason Liu <jason.hui@linaro.org>
> > Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> > Cc: Sascha Hauer <s.hauer@pengutronix.de>
> > ---
> >  .../bindings/tty/serial/fsl-imx-uart.txt           |   21 +++++
> >  drivers/tty/serial/imx.c                           |   81 ++++++++++++=
+++++---
> >  2 files changed, 92 insertions(+), 10 deletions(-)
> >  create mode 100644 Documentation/devicetree/bindings/tty/serial/fsl-im=
x-uart.txt
> >=20
> > diff --git a/Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.=
txt b/Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.txt
> > new file mode 100644
> > index 0000000..7648e17
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.txt
> > @@ -0,0 +1,21 @@
> > +* Freescale i.MX Universal Asynchronous Receiver/Transmitter (UART)
> > +
> > +Required properties:
> > +- compatible : should be "fsl,<soc>-uart", "fsl,imx-uart"
>=20
> I'd make this "fsl,<soc>-uart", "fsl,imx51-uart"
>=20
> It's better to anchor these things on real silicon, or a real ip block
> specification rather than something pseudo-generic.  Subsequent chips,
> like the imx53, should simply claim compatibility with the older
> fsl,imx51-uart.
>=20
> (in essence, "fsl,imx51-uart" becomes the generic string without the
> downside of having no obvious recourse when new silicon shows up that
> is an imx part, but isn't compatible with the imx51 uart.

Shouldn't that be the oldest SoC this core showed up? It might be an academ=
ic
question, but it would look a bit funny if mx27 got dt-support and would ha=
ve a
imx51-uart? The first imx to have this core is the mx1. (Although there are
some cpu_is_mx1() calls used in the driver, but they are still available, o=
r?)

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--DrWhICOqskFTAXiy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEARECAAYFAk39nw0ACgkQD27XaX1/VRtl2wCgu/g3mtisRr4cQ/8mCuEye+KB
EJYAnjTluNJAV/A18/6VwAHX6doVyZxB
=/xem
-----END PGP SIGNATURE-----

--DrWhICOqskFTAXiy--
