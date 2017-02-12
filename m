From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH V5 for-next 21/21] RDMA/bnxt_re: Add bnxt_re driver build
 support
Date: Sun, 12 Feb 2017 09:54:49 +0200
Message-ID: <20170212075449.GA14015@mtr-leonro.local>
References: <1486725593-9872-1-git-send-email-selvin.xavier@broadcom.com>
 <1486725593-9872-22-git-send-email-selvin.xavier@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="mP3DRpeJDSE+ciuQ"
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Selvin Xavier <selvin.xavier@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:53828 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750780AbdBLHyo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 02:54:44 -0500
Content-Disposition: inline
In-Reply-To: <1486725593-9872-22-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--mP3DRpeJDSE+ciuQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Feb 10, 2017 at 03:19:53AM -0800, Selvin Xavier wrote:
> Makefile and Kconfig changes for enabling bnxt_re compilation
>
> v3: Adds list of MAINTAINERS of bnxt_re driver. Removes bnxt_re_debugfs.c
>     from Makefile as this file is no longer present
>
> Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
> Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
> ---
>  MAINTAINERS                            | 11 +++++++++++
>  drivers/infiniband/Kconfig             |  2 ++
>  drivers/infiniband/hw/Makefile         |  1 +
>  drivers/infiniband/hw/bnxt_re/Kconfig  |  9 +++++++++
>  drivers/infiniband/hw/bnxt_re/Makefile |  6 ++++++
>  5 files changed, 29 insertions(+)
>  create mode 100644 drivers/infiniband/hw/bnxt_re/Kconfig
>  create mode 100644 drivers/infiniband/hw/bnxt_re/Makefile
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 5f0420a..468d2e8 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -2808,6 +2808,17 @@ L:	linux-arm-kernel@lists.infradead.org (moderated for non-subscribers)
>  S:	Maintained
>  F:	arch/arm64/boot/dts/broadcom/vulcan*
>
> +BROADCOM NETXTREME-E ROCE DRIVER
> +M:	Selvin Xavier <selvin.xavier@broadcom.com>
> +M:	Devesh Sharma <devesh.sharma@broadcom.com>
> +M:	Somnath Kotur <somnath.kotur@broadcom.com>
> +M:	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> +L:	linux-rdma@vger.kernel.org
> +W:	http://www.broadcom.com
> +S:	Supported
> +F:	drivers/infiniband/hw/bnxt_re/
> +F:	include/uapi/rdma/bnxt_re-abi.h
> +

Please take a look on the note which I gave to Faisal a long time ago [1].
Our experience shows that the more people you add here, the less chances
to be CCed on the relevant patches.

It is definitely up to you.

Thanks,
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

[1] https://www.spinics.net/lists/linux-rdma/msg41457.html

--mP3DRpeJDSE+ciuQ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAligFMkACgkQ5GN7iDZy
WKdEeBAAmG98PiNXIjvBTNyK1OA7CalYPcWIHCJrBRu/0F5+c9TynITQ3BSBcz0x
6YP2cYepgTyNbMTvYH8Qz/mCWvI7smEQZFwgRJxlW+fG6zjNYSFt0t+LYrOUQKDn
JDDkPKUbSnHlz0b18Nh6tknTbY4GHFnEHbYly0KCwytwMd6zHidTHkw/Fu05v9YG
5Z600Mq/GfkawfsSqXG1skrkdrPOuSC1AmigFkpc6mUHh8f2u6rUZTQjZAFaKJSk
Ejt5Y08ZEtncJ+8kbspvtjhLRjgSasn4B4H6WlV79L2Wa5580Ushnl9J8uF4FhQe
w9QrxvYS+FQkvGfchzH0YiXLV2kZ+xXnmGZrtjSS0e/uTRFc62J/OfdK+WnKpnag
NuqvUwNx7YWfSpQ/t8F0YJ2H44JhsSo6VuIxqE0l5sVEUn6VBcdMN05pOyz4jjKx
tZBeWC/kUSbdPxhkBawnZJeOkKVcf4Y01S2JYYIZWW8wuuJ4PtYHDaKphILRdQaf
My7iw9kOT1Zp43F2T8n23HFipVrqg8p1+SsXdkYuemnkQB4wwJ9KxY3urvaXwO4s
+HIA2iT1vl4Lr6btgTn03OMKhMO5G0oJE8F4SLrejlAgF9HJ5Edk9H55i3z9W6jp
ysHfqTBCcTOQrrf31gEWCOTxzAwXdQIH8wVaDyCUQ0dIyYd8VCY=
=ETDW
-----END PGP SIGNATURE-----

--mP3DRpeJDSE+ciuQ--
