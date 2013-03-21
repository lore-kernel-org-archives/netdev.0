From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 3/5] net/mlx4_en: Remove ethtool flow steering rules
 before releasing QPs
Date: Thu, 21 Mar 2013 21:28:08 +0300
Message-ID: <514B5138.4040106@cogentembedded.com>
References: <1363881355-21137-1-git-send-email-ogerlitz@mellanox.com> <1363881355-21137-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, amirv@mellanox.com,
	jackm@dev.mellanox.co.il, hadarh@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:49665 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228Ab3CUR0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 13:26:48 -0400
Received: by mail-la0-f41.google.com with SMTP id fo12so5675132lab.28
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 10:26:46 -0700 (PDT)
In-Reply-To: <1363881355-21137-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/21/2013 06:55 PM, Or Gerlitz wrote:

> From: Hadar Hen Zion <hadarh@mellanox.com>
>
> Fix the ethtool flow steering rules cleanup to be carried out before
> releasing the RX QPs.
>
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   22 +++++++++++-----------
>   1 files changed, 11 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 995d4b6..f278b10 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -1637,6 +1637,17 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
>   	/* Flush multicast filter */
>   	mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, 0, 1, MLX4_MCAST_CONFIG);
>   
> +	/* Remove flow steering rules for the port*/

    Could you add a space before */, despite it was missing before?

WBR, Sergei
