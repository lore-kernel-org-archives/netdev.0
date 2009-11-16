From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH] net/can: add driver for mscan family & mpc52xx_mscan
Date: Mon, 16 Nov 2009 11:24:14 +0100
Message-ID: <20091116102414.GB30609@pengutronix.de>
References: <1258128892-28800-1-git-send-email-w.sang@pengutronix.de>
	<4B0110D5.6010405@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1981139868=="
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4B0110D5.6010405-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============1981139868==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="8P1HSweYDcXXzwPJ"
Content-Disposition: inline


--8P1HSweYDcXXzwPJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Wolfgang,

On Mon, Nov 16, 2009 at 09:44:05AM +0100, Wolfgang Grandegger wrote:
> Hi Wolfram,
>=20
> thanks for pushing this driver to mainline. I think you should also add
> a CC to the Devicetree-discuss ML.

thank you very much for your review! I agree with nearly all of your points=
 and will
send an update today. The only thing I have doubts about is removing those =
lines:

> +MODULE_AUTHOR("Andrey Volkov <avolkov-ppI4tVfbJvJWk0Htik3J/w@public.gmane.org>");
> +MODULE_LICENSE("GPL v2");
> +MODULE_DESCRIPTION("CAN port driver for a MSCAN based chips");

I looked around in the kernel sources and found that they are often present=
 in
generic modules, even if they can't be used without a wrapper (examples are=
 all
files in drivers/i2c/algos or drivers/net/wireless/iwlwifi/iwl-core.c). As =
I'm
also a bit anxious to fiddle with other people's authorship, I'd prefer to =
keep
them.

Finally, I'll also try to test suspend/resume, but I have to find out if it=
 is
supported on that board in general.

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--8P1HSweYDcXXzwPJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAksBKE4ACgkQD27XaX1/VRtMogCgj132nU0J0Jp3XgwdhUox6ljL
Ii8AnjYgcP1nRMr0ebFSaOh5nbLeoXEM
=GXE/
-----END PGP SIGNATURE-----

--8P1HSweYDcXXzwPJ--

--===============1981139868==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============1981139868==--
