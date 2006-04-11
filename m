From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: bcm43xx symbol clash problems
Date: Tue, 11 Apr 2006 08:39:40 +0200
Message-ID: <1144737580.4888.25.camel@localhost>
References: <200604100216.21571.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-oAHtuoN7L0m2qKkeng4G"
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
   bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
In-Reply-To: <200604100216.21571.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org


--=-oAHtuoN7L0m2qKkeng4G
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2006-04-10 at 02:16 +0200, Michael Buesch wrote:
> Does kbuild perhaps have some magic to handle that?
>=20
> This needs to be solved soon, but I have no idea how.

You want to have bcm43xx and bcm43xx-dscape conflict anyway, since
there's no point in building both into the kernel, only one can be bound
to a device. Yes, I know one could still bind them manually, but that's
about as icky as building them as modules imho. And whoever really needs
a static kernel will not need both of them.

I don't know how the Kconfig there is laid out, but wouldn't it be
possible to make them conflict on both yes?

johannes

--=-oAHtuoN7L0m2qKkeng4G
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARDtPKaVg1VMiehFYAQIt5Q//QItZrVuzPKiD7X5/vNsNCFOI2dFrSfeN
CafQPdf1A9NgKDQYh/oZmC7rEBFAtSCpTJtOBSYaH9iklct03Fpcyfgt7YwZBJcf
hFYLyILVxvHGHbSiVYklsAAM02MOqSmoSEAyF1GXmg2h7M8dqIXfYEcISiqgZUbn
49Ls/ueAQLKCz299ZnPFAmrXBQRZnfC0QKYjaWJod/BQmH+crPll5dkiEnFWNbkh
16N8rnyoxpohI2ScMG0Lq9ItXLNHzPzhtg4A0FXZiASmm15T9CPKssFSYGnwOAjY
8KTPm69OuyBTxjQL1iYyklHnv2A8MH8uRsrj+FHBrZjxCRGdGjXF94ymXA0UgW1z
H3Puk+rX/kG7pbUSk3CgsSDDMqYIFBnGn4NBZFqwhKnXds2WdX8oYaqupkCzfADs
YrbUwiw2Md0dfKqklvf+rgtLPrfeEnDwnN+S/68KGoGMtVgtxuYim95Zsn31XCUU
uBAFeYTcUt6p+WuNUcqJpvtXiCJbo37a8HK/S3X7RSzSp50ZNFeoQvmHSWTJZBw1
/M3ALsm+M7rcQjqR+HCfF+GQoluiIwb7qNP/FAI0U3bsp2Lh2eA3GhA8kO54NJq9
vF055KUCJYlBzMyn4qaReq8muJhyibhpIvLyTb182R2MlM6mVdQ7NpdgBw9rxBnE
TGI0zDL2bdQ=
=X9tG
-----END PGP SIGNATURE-----

--=-oAHtuoN7L0m2qKkeng4G--
