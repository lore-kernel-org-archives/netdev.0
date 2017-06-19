From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net-next 09/13] net: ena: adding missing cast in
 ena_com_mem_addr_set()
Date: Mon, 19 Jun 2017 08:00:09 +0300
Message-ID: <20170619050009.GK17846@mtr-leonro.local>
References: <1497785298-13468-1-git-send-email-netanel@amazon.com>
 <1497785298-13468-10-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="M0YLxmUXciMpOLPE"
Cc: davem@davemloft.net, netdev@vger.kernel.org, dwmw@amazon.com,
        zorik@amazon.com, matua@amazon.com, saeedb@amazon.com,
        msw@amazon.com, aliguori@amazon.com, nafea@amazon.com,
        evgenys@amazon.com
To: netanel@amazon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:50874 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750790AbdFSFAN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Jun 2017 01:00:13 -0400
Content-Disposition: inline
In-Reply-To: <1497785298-13468-10-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--M0YLxmUXciMpOLPE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Jun 18, 2017 at 02:28:14PM +0300, netanel@amazon.com wrote:
> From: Netanel Belgazal <netanel@amazon.com>
>
> Signed-off-by: Netanel Belgazal <netanel@amazon.com>
> ---
>  drivers/net/ethernet/amazon/ena/ena_com.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
> index f6e1d30523a6..8efb85e25a42 100644
> --- a/drivers/net/ethernet/amazon/ena/ena_com.c
> +++ b/drivers/net/ethernet/amazon/ena/ena_com.c
> @@ -100,7 +100,7 @@ static inline int ena_com_mem_addr_set(struct ena_com_dev *ena_dev,
>  	}
>
>  	ena_addr->mem_addr_low = (u32)addr;
> -	ena_addr->mem_addr_high = (u64)addr >> 32;
> +	ena_addr->mem_addr_high = (u16)((u64)addr >> 32);

We have macro for getting upper 32 bits - upper_32_bits(addr), the same
goes for lower 32 bits.

>
>  	return 0;
>  }
> --
> 2.7.4
>

--M0YLxmUXciMpOLPE
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllHWlkACgkQ5GN7iDZy
WKdn5g/+LJZKfiWg3jD8tV9MGgApj/sQk3njFJ297bIztFN52XAV239lu3dLcgCZ
1EWTHakwSGoCjTUlNIM5r1BYFkL9/dFVWy0pojTQedN3d3eecl9RKo6SjM9M8P3G
iRdhaLKJW9yLEr/wXJv+q1dMEvHwWDkwDyBZiv9T+qpOwXRWBfBnbeVfTPOsficz
qmKJzS4LtYGnsUqZI+WGZbtLluUQTOtxuukMWjbOllOu/R9p6RuN4rQQS/B6lwvp
cNpIkpSEKxWv9k9zn1ZR9g+kk3dWKUeH5T3y4J7tY7hrjQ5vegpuaVvHtUt7kGWS
g76htmTkZO2Hcwk9vGT8Aj/f7buCb+melH5HkMNDPVx/040L7B4UPdSlmNN1yi+z
nxBz5zMVicQsZKOw14ECPUK1Q4sQxE2ucxNKMc2wr+BRQuVEi6c/if37LjuKp9Xe
VRmNqdga/GGVn4/NhE4ptNg4eloh/g+aUfeF9i1MzisEnzMwvMw5I0IRPTNELJY0
nRfWEaRyeqFRvwbXt9N3LA0xguzhByfoEqfsMfzGdh5oN2DDuVO1OI7WhKwt4w6n
//piPEFszMGLvNLr2h5zP/DXMbaCzeF5LaQAg/26lspm6HRlP4d7VROFqH6ifIOq
VLF0MBkYHZTwo74BxzXZepwPw2lKHMG1CfdYupLVVa4m6uyGrbo=
=bIij
-----END PGP SIGNATURE-----

--M0YLxmUXciMpOLPE--
