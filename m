From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH for bnxt_re V4 09/21] RDMA/bnxt_re: Support for GID
 related verbs
Date: Wed, 18 Jan 2017 11:50:06 +0200
Message-ID: <20170118095006.GX32481@mtr-leonro.local>
References: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
 <1482320530-5344-10-git-send-email-selvin.xavier@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="xbjSOCWVZ1q9zj4g"
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, michael.chan@broadcom.com,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Selvin Xavier <selvin.xavier@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:36746 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752494AbdARJuP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 04:50:15 -0500
Content-Disposition: inline
In-Reply-To: <1482320530-5344-10-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--xbjSOCWVZ1q9zj4g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Dec 21, 2016 at 03:41:58AM -0800, Selvin Xavier wrote:
> Implements add GID, del GID,  get_netdev and pkey related verbs.
>
> v3: Fixes some sparse warning related to endianness check. Removes
>     macros which are just wrapper for standard defines.
>
> Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
> Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
> Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
> ---
>  drivers/infiniband/hw/bnxt_re/ib_verbs.c  | 123 +++++++++++++++++
>  drivers/infiniband/hw/bnxt_re/ib_verbs.h  |  18 +++
>  drivers/infiniband/hw/bnxt_re/main.c      |   7 +
>  drivers/infiniband/hw/bnxt_re/qplib_res.c |   5 +
>  drivers/infiniband/hw/bnxt_re/qplib_res.h |   3 +
>  drivers/infiniband/hw/bnxt_re/qplib_sp.c  | 218 ++++++++++++++++++++++++++++++
>  drivers/infiniband/hw/bnxt_re/qplib_sp.h  |  11 ++
>  7 files changed, 385 insertions(+)
>

<snip>

> +
> +int bnxt_qplib_del_sgid(struct bnxt_qplib_sgid_tbl *sgid_tbl,
> +			struct bnxt_qplib_gid *gid, bool update)
> +{
> +	struct bnxt_qplib_res *res = to_bnxt_qplib(sgid_tbl,
> +						   struct bnxt_qplib_res,
> +						   sgid_tbl);
> +	struct bnxt_qplib_rcfw *rcfw = res->rcfw;
> +	int index;
> +
> +	if (!sgid_tbl) {
> +		dev_err(&res->pdev->dev, "QPLIB: SGID table not allocated");
> +		return -EINVAL;
> +	}
> +	/* Do we need a sgid_lock here? */

It is better to answer on this question before acceptance.

> +	if (!sgid_tbl->active) {
> +		dev_err(&res->pdev->dev,
> +			"QPLIB: SGID table has no active entries");
> +		return -ENOMEM;
> +	}

--xbjSOCWVZ1q9zj4g
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh/Ok4ACgkQ5GN7iDZy
WKeI6xAAjH8jSeR/jYvqMfI3MGuobn1VD+m/y4KTy3wXXHB8YVElvdvjuLlEEYmS
S/mRVNz9sFEB88pBvD61v8hAadSs29uRoqZePAAmb4r48hFza2XUm2kfB2q6QpCn
GeRh0QKxmG8o5mFhXA05niDWyXK9u2BgABHCBjsuAVavBWPgNPv7bo66+nugaoA1
eB4xm6uTE4EHbFsSwq6F59mKmaKoHK5n+ndTocJTnG7aHudPcLVenP50yiU93QkT
r/pKdGIKwAmMgkDR6kG8vXTC7EQFtdZljcx8TUhWNkYaYoOq13ZO7innkh7YMcfS
w4zuuoot+ADtFu7PgeHLeTmsSr8duAOlgoQpyZWFhyBgXDonB7gHCC2I1V/sl2VZ
gJLAMzB8XY094cP8F4rYiLXpPZ/NNsu5LkF5OLbAkuitwzQvBGGHRNpxHk8sl29G
Xtviowbp9YY+N6aJvkP4qu/L6VlZAzoiF8hs380mrPLqjPG4vVl47DfOOEDZBQRR
ZjjaGItoGMGAew2fK7/VeN7u9id/e94UHUnvZWxwt3MuApPkteNxhISFhO3cbSZN
IFTUcYjwPEgnM34bbAd1smKwNhs0htVwsESOo5V3cGXkyFk4jntX7g1DhL0exT7s
UgXF6zJwIunZjtYa2iSXpYLc5pp5+6dTNv5ZWeJXfgwiVAnnNIk=
=ck5U
-----END PGP SIGNATURE-----

--xbjSOCWVZ1q9zj4g--
