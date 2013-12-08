From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 07/12] net/mlx4_en: Configure the XPS queue mapping
 on driver load
Date: Sun, 08 Dec 2013 19:28:30 +0400
Message-ID: <52A4901E.2030906@cogentembedded.com>
References: <1386506152-10298-1-git-send-email-amirv@mellanox.com> <1386506152-10298-8-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:39809 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755254Ab3LHP2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 10:28:33 -0500
Received: by mail-la0-f51.google.com with SMTP id ec20so987748lab.10
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 07:28:32 -0800 (PST)
In-Reply-To: <1386506152-10298-8-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08-12-2013 16:35, Amir Vadai wrote:

> From: Ido Shamay <idos@mellanox.com>

> Only TX rings of User Piority 0 are mapped.
> TX rings of other UP's are using UP 0 mapping.
> XPS is not in use when num_tc is set.

> Signed-off-by: Ido Shamay <idos@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
[...]

> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index fa33a83..a4cdd7d 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
[...]
> @@ -708,8 +710,9 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb);
>   netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev);
>
>   int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
> -			   struct mlx4_en_tx_ring **pring,
> -			   int qpn, u32 size, u16 stride, int node);
> +			struct mlx4_en_tx_ring **pring,
> +			int qpn, u32 size, u16 stride,
> +			int node, int queue_index);

    Why you've changed the indentation here -- it was alright before.

>   void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
>   			     struct mlx4_en_tx_ring **pring);
>   int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,

WBR, Sergei
