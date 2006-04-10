From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC/PATCH] remove unneeded check in bcm43xx
Date: Mon, 10 Apr 2006 06:07:32 +0200
Message-ID: <200604100607.33362.mb@bu3sch.de>
References: <20060410040120.GA4860@ens-lyon.fr>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1809729.AZ0Zxlm8vr";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
   linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
   benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Benoit Boissinot <benoit.boissinot-vYW+cPY1g1pg9hUCZPvPmw@public.gmane.org>
In-Reply-To: <20060410040120.GA4860-vYW+cPY1g1pWj0EZb7rXcA@public.gmane.org>
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

--nextPart1809729.AZ0Zxlm8vr
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 10 April 2006 06:01, you wrote:
> Since the driver already sets the correct dma_mask, there is no reason
> to bail there. In fact if you have an iommu, I think you can have a
> address above 1G which will be ok for the device (if it isn't true then
> the powerpc dma_alloc_coherent with iommu needs to be fixed because it
> doesn't respect the the dma_mask).
>=20
> Please comment or apply.

NACK. Don't apply that patch.
I know it is odd, but people are actually hitting these messages.
Maybe benh can explain the issues. I don't know...

=2D-=20
Greetings Michael.

--nextPart1809729.AZ0Zxlm8vr
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBEOdoFlb09HEdWDKgRAt3bAKCInf21ju7xYfsQjmf/6au74GwUfgCfcUt2
f+FkUw4JGXf3uqlM6VSxNaM=
=jZAG
-----END PGP SIGNATURE-----

--nextPart1809729.AZ0Zxlm8vr--
