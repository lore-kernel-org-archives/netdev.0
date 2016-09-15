From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC 08/11] Add support for data path
Date: Thu, 15 Sep 2016 10:24:50 +0300
Message-ID: <20160915072450.GR26069@leon.nu>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-9-git-send-email-Ram.Amrani@qlogic.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="0Qexx6XJGNEACt6j"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
        Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
        rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1473696465-27986-9-git-send-email-Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--0Qexx6XJGNEACt6j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Sep 12, 2016 at 07:07:42PM +0300, Ram Amrani wrote:

> +++ b/drivers/infiniband/hw/qedr/qedr_hsi_rdma.h
> @@ -150,6 +150,12 @@ struct rdma_rq_sge {
>  	struct regpair addr;
>  	__le32 length;
>  	__le32 flags;
> +#define RDMA_RQ_SGE_L_KEY_MASK      0x3FFFFFF
> +#define RDMA_RQ_SGE_L_KEY_SHIFT     0
> +#define RDMA_RQ_SGE_NUM_SGES_MASK   0x7
> +#define RDMA_RQ_SGE_NUM_SGES_SHIFT  26
> +#define RDMA_RQ_SGE_RESERVED0_MASK  0x7
> +#define RDMA_RQ_SGE_RESERVED0_SHIFT 29
>  };

It is interesting twist to mix defines and structs together.

--0Qexx6XJGNEACt6j
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX2kzCAAoJEORje4g2clinldYQALhcG8jsSv3pzwNGq3iO+MSw
oaZ5tm7L97B7b3WRkfSIw+oCbhu40k+SxzBZomqplHVH13+HOU0GMyx+vmdbhQqK
xGoIoryKSqc5rEE7WkSAJtmQzzKxZRlX5/PUWc8fVz0QAg/20YwrE379yu1jxKAR
w6ppI+90NZFK+CTcMY0VdIBgvYvv2UfAPiBVGJleH7CbPcodjc/d+ux0lY/PRlWE
b2GUsAFPBy4Ek1RaR/tro7nMDL85F8VzS122UBoeHlBn/zTVIejekj00l5INtyUH
7nakky0QsXy45fCcr0xQTnviv3x8fzpFdWnvEOQT6xQ5RKk/kxGa/0i6OcClWpXH
crjMaKuXqfkdO/wDYrS9bCW6HdYDI1ql91UZsCLdB7vqXIPvdWvryQZnPlELPGY2
pKDCt04yadOkidoA3NEukPm52f/CXZNzg2NV5XAd1hBwJ21NNk4kZu9dFkajt0xt
opVSHL3GlObL61UvkUWQ/mJZPM2XXFuHIF2rkBrQrmQrzNPlIbmScaYNUIJHgxau
KE4dTCiI5XNLkuusyYPjJAhS4rdy3MRsFxJaJ63MMWaUs+/aMGNvGmqY9+Iqm6GQ
VrugAkOQqPNs2Vo1y5BOKL1odIOD7XJBgW+kgdl52ycMT5ifHEgAOMeJRsByeYkF
rbywmYmPnj0MJ1ikr3YP
=/kmy
-----END PGP SIGNATURE-----

--0Qexx6XJGNEACt6j--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
