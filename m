From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2/2] s2io: add missing block braces to multistatement if statement
Date: Tue, 13 May 2008 12:22:35 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77039236ED@nekter>
References: <1210677414-16380-1-git-send-email-ilpo.jarvinen@helsinki.fi> <1210677414-16380-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	"Rastapur Santosh" <santosh.rastapur@neterion.com>,
	"Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
To: =?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:13779 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752774AbYEMQWf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 12:22:35 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1210677414-16380-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

Patch looks good. Please accept.

Thanks,
Ram

> -----Original Message-----
> From: Ilpo J=E4rvinen [mailto:ilpo.jarvinen@helsinki.fi]
> Sent: Tuesday, May 13, 2008 4:17 AM
> To: Jeff Garzik
> Cc: netdev@vger.kernel.org; Ilpo Jrvinen; Ramkrishna Vepa; Rastapur
> Santosh; Sivakumar Subramani; Sreenivasa Honnur
> Subject: [PATCH 2/2] s2io: add missing block braces to multistatement=
 if
> statement
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> Cc: Ramkrishna Vepa <ram.vepa@neterion.com>
> Cc: Rastapur Santosh <santosh.rastapur@neterion.com>
> Cc: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> Cc: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> ---
>  drivers/net/s2io.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index 523478e..0f3d230 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -1113,9 +1113,10 @@ static int s2io_on_nec_bridge(struct pci_dev
> *s2io_pdev)
>  	struct pci_dev *tdev =3D NULL;
>  	while ((tdev =3D pci_get_device(PCI_ANY_ID, PCI_ANY_ID, tdev)) !=3D
> NULL) {
>  		if (tdev->vendor =3D=3D NEC_VENID && tdev->device =3D=3D NEC_DEVID=
) {
> -			if (tdev->bus =3D=3D s2io_pdev->bus->parent)
> +			if (tdev->bus =3D=3D s2io_pdev->bus->parent) {
>  				pci_dev_put(tdev);
>  				return 1;
> +			}
>  		}
>  	}
>  	return 0;
> --
> 1.5.2.2

