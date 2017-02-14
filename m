From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH V5 for-next 10/21] RDMA/bnxt_re: Support for CQ verbs
Date: Tue, 14 Feb 2017 14:22:12 +0200
Message-ID: <20170214122212.GJ6989@mtr-leonro.local>
References: <1486725593-9872-1-git-send-email-selvin.xavier@broadcom.com>
 <1486725593-9872-11-git-send-email-selvin.xavier@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="X1xGqyAVbSpAWs5A"
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Selvin Xavier <selvin.xavier@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:50870 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753064AbdBNMWI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 07:22:08 -0500
Content-Disposition: inline
In-Reply-To: <1486725593-9872-11-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--X1xGqyAVbSpAWs5A
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Feb 10, 2017 at 03:19:42AM -0800, Selvin Xavier wrote:
> Implements support for create_cq, destroy_cq and req_notify_cq
> verbs.
>
> v3: Code cleanup based on errors reported by sparse on endianness check.
>     Removes unwanted macros.
> v5: Use min_t macro to calculate the CQ entries
>
> Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
> Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
> Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
> ---

<...>

> diff --git a/drivers/infiniband/hw/bnxt_re/qplib_fp.h b/drivers/infiniband/hw/bnxt_re/qplib_fp.h
> index 78e1717..1dfc86d 100644
> --- a/drivers/infiniband/hw/bnxt_re/qplib_fp.h
> +++ b/drivers/infiniband/hw/bnxt_re/qplib_fp.h
> @@ -38,6 +38,52 @@
>
>  #ifndef __BNXT_QPLIB_FP_H__
>  #define __BNXT_QPLIB_FP_H__
> +#define BNXT_QPLIB_MAX_CQE_ENTRY_SIZE	sizeof(struct cq_base)
> +

IMHO, this define is redundant.
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

Thanks

--X1xGqyAVbSpAWs5A
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlii9nQACgkQ5GN7iDZy
WKcNoBAAlN2rHdvEkMi8E0On4qn6LZal62HDcg3iQqamaQnNU2TbW5uiBJS0Uz0K
nFzzC8X0wIVJBCTdVZkxR0B6G3/tu2FQopCibuSz40l+eOBmzEvCtGfLV1Mf5zDK
nnMmQBkqoqLYnTAAX/a+2Te/122R/BMsN4oNCBLK4AtAFTMUh6T72z9L/Eobg4Fu
Z49D80qmgEwRY5iV1LhRy+KUSTmZNx0g68DKOx7ueoCS8Fg6g74uWcwJvSw4f5XF
ChfPyNN2tvbL93YTXd1xbbVKmq4XrfWZdGzqVzvo71cmHcBoWVWSbWapKpTkc4yB
8ZzhPMHrwGrjc7F+1xyNZFS103bdQYzzMaJNKv5/+JWciGb8Ety2ZcpOlUPn+oPL
43XmyKVQ/Qvp7B900U0954OBjQuUeQr91GWy9qoABsDtqipupOn5tnC9hWVqdaXn
0kWKNHAPVdNmlpT8tBbqqlhyQpXi3sAWWkZj0zaA0tep5oqGhAZLpFJ8x7FgFETK
3PJ5KXNMzrzWhVdHxDiPRIgXujMz+zfbc0m0/1d+16vCErEt+ax15Mqu15nY1NIs
qHUDCExCxFoUOUut6VO9hlZ635oBxsvwOtv+rZ1i9Nvd0FaLIfCKhxl4oulMsTLV
O7oiSBFW8EaOD97PJ/XhbyfKR9q/nlQ9FgwVQbHjIMkyF6JSWTs=
=sqSJ
-----END PGP SIGNATURE-----

--X1xGqyAVbSpAWs5A--
