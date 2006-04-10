From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC/PATCH] remove unneeded check in bcm43xx
Date: Mon, 10 Apr 2006 06:28:00 +0200
Message-ID: <200604100628.01483.mb@bu3sch.de>
References: <20060410040120.GA4860@ens-lyon.fr> <200604100607.33362.mb@bu3sch.de> <20060410042228.GN27596@ens-lyon.fr>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3112089.dRx02SJYqy";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
   linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
   benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Benoit Boissinot <benoit.boissinot-vYW+cPY1g1pg9hUCZPvPmw@public.gmane.org>
In-Reply-To: <20060410042228.GN27596-vYW+cPY1g1pWj0EZb7rXcA@public.gmane.org>
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

--nextPart3112089.dRx02SJYqy
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 10 April 2006 06:22, you wrote:
> Either the ppc code is wrong (it doesn't enforce dma_mask) either the
> driver still works without the check.
>=20
> Maybe ppc should do the same thing as i386:
>=20
> 47         if (dev =3D=3D NULL || (dev->coherent_dma_mask < 0xffffffff))
> 48                 gfp |=3D GFP_DMA;

No, GFP_DMA is a NOP on PPC.
Actually the problems seems much more complex and a correct fix
seems to be hard to do.
I think benh is actually fixing this.

To summerize: I actually added these messages, because people were
hitting "this does not work with >1G" issues and did not get an error messa=
ge.
So I decided to insert warnings until the issue is fixed inside the arch co=
de.
I will remove them once the issue is fixed.

=2D-=20
Greetings Michael.

--nextPart3112089.dRx02SJYqy
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBEOd7Rlb09HEdWDKgRAh6OAJ9fL3QpHb10LA8/ih1+u9pNIb77uwCgkXXD
lKZ5HphLno7YZT9R1t08GXI=
=IqNS
-----END PGP SIGNATURE-----

--nextPart3112089.dRx02SJYqy--
