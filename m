From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v12 3/6] flexcan: Fix up fsl-flexcan device tree binding.
Date: Mon, 15 Aug 2011 18:13:45 +0200
Message-ID: <4E4945B9.2020201@pengutronix.de>
References: <1313138752-24006-1-git-send-email-holt@sgi.com>
	<1313138752-24006-4-git-send-email-holt@sgi.com>
	<20110815150357.GM4926@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1435794236241750116=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110815150357.GM4926-sJ/iWh9BUns@public.gmane.org>
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
--===============1435794236241750116==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig3856E2123D9DE0B80222F236"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig3856E2123D9DE0B80222F236
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/15/2011 05:03 PM, Robin Holt wrote:
> Earlier, you had asked for a more specific name for the compatible
> property of the Freescale flexcan device.  I still have not gotten a
> more specific answer.  Hopefully Marc can give you more details about
> the flexcan implementations.

There are at least 2 versions of the flexcan ip core in the wild. Due to
lack of version numbers or other names I call them old and new here :).

The newer one supports rx fifo mode, whereas the older one doesn't. The
mainline flexcan driver just supports the new core [1]. The older core
is found on coldfire processors. I don't know if there are coldfire cpus
with the new flexcan core, too. The driver can be adopted to the old
core if needed.

The first cpus with the new core I got in touch with was the mx35
(arm11) and mx25 (arm9) both at the same time. Ask fsl which one was
released first. After this there was mx28 (arm9) and there should be an
mx53 (coretexa8) with flexcan too.

> Other than an agreement on the compatible property, I believe we have
> agreement on all the other code changes in these patches.  Is this chan=
ge
> acceptable as is and if we get a better resolution on the fsl,flexcan
> name later, we can update the documentation and driver then?

cheers, Marc

[1] http://lxr.linux.no/linux+v3.0.1/drivers/net/can/flexcan.c#L871

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig3856E2123D9DE0B80222F236
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk5JRbwACgkQjTAFq1RaXHMlAgCeLCfI0CuYJRapp88vYkdlauBf
arUAoI6CTN3jhmmFsf355McyGVf7sSV4
=YPDm
-----END PGP SIGNATURE-----

--------------enig3856E2123D9DE0B80222F236--

--===============1435794236241750116==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============1435794236241750116==--
