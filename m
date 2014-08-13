From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 02/10] IB/mlx5: Add support for extended query
 device
Date: Wed, 13 Aug 2014 16:29:00 +0400
Message-ID: <53EB5A0C.8040209@cogentembedded.com>
References: <1407929951-16362-1-git-send-email-eli@mellanox.com> <1407929951-16362-3-git-send-email-eli@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdma@vger.kernel.org, amirv@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: Eli Cohen <eli@dev.mellanox.co.il>, roland@kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:47853 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbaHMM3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 08:29:04 -0400
Received: by mail-lb0-f182.google.com with SMTP id z11so8287232lbi.27
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 05:29:02 -0700 (PDT)
In-Reply-To: <1407929951-16362-3-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/13/2014 3:39 PM, Eli Cohen wrote:

> Add a new entry for query device extended which currently has identical
> functionality to query_device and publish support for it.

> Signed-off-by: Eli Cohen <eli@mellanox.com>
> ---
>   drivers/infiniband/hw/mlx5/main.c | 25 +++++++++++++++++++++++--
>   1 file changed, 23 insertions(+), 2 deletions(-)

> diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
> index d8907b20522a..63fddeec90af 100644
> --- a/drivers/infiniband/hw/mlx5/main.c
> +++ b/drivers/infiniband/hw/mlx5/main.c
[...]
> @@ -775,6 +781,17 @@ static int mlx5_ib_dealloc_pd(struct ib_pd *pd)
>   	return 0;
>   }
>
> +static int mlx5_ib_query_device_ex(struct ib_device *device,
> +				   struct ib_device_attr *attr,
> +				   struct ib_udata *uhw)
> +{
> +	int err;
> +
> +	err = query_device(device, attr);
> +
> +	return err;
> +}

   Why not just:

	return query_device(device, attr);

WBR, Sergei
