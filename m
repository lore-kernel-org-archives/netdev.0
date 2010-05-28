From: Andrew Grover <andy.grover@gmail.com>
Subject: Re: [patch 3/3] rds/iw_rdma: remove unneeded kfree()
Date: Fri, 28 May 2010 00:38:05 -0700
Message-ID: <AANLkTilQJJ2k27gwF8VcrUTR3L9JU-7D_hCphEZp4CSy@mail.gmail.com>
References: <20100527091128.GT22515@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Grover <andy.grover@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:61725 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754552Ab0E1HiH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 03:38:07 -0400
In-Reply-To: <20100527091128.GT22515@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Dan, nice catches.

=46or all three:

Acked-by: Andy Grover <andy.grover@oracle.com>

-- Andy

On Thu, May 27, 2010 at 2:11 AM, Dan Carpenter <error27@gmail.com> wrot=
e:
> The "dma_pages" variable is always NULL at this point so the kfree()
> isn't needed.
>
> Signed-off-by: Dan Carpenter <error27@gmail.com>
>
> diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
> index 48d5073..742ab6a 100644
> --- a/net/rds/iw_rdma.c
> +++ b/net/rds/iw_rdma.c
> @@ -334,7 +334,6 @@ static u64 *rds_iw_map_scatterlist(struct rds_iw_=
device *rds_iwdev,
> =A0out_unmap:
> =A0 =A0 =A0 =A0ib_dma_unmap_sg(rds_iwdev->dev, sg->list, sg->len, DMA=
_BIDIRECTIONAL);
> =A0 =A0 =A0 =A0sg->dma_len =3D 0;
> - =A0 =A0 =A0 kfree(dma_pages);
> =A0 =A0 =A0 =A0return ERR_PTR(ret);
> =A0}
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
