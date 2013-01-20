From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next] net/mlx4_en: remove redundant code
Date: Sun, 20 Jan 2013 16:48:26 +0200
Message-ID: <50FC03BA.8020200@mellanox.com>
References: <1358423241-2452-1-git-send-email-amirv@mellanox.com>  <1358423241-2452-6-git-send-email-amirv@mellanox.com>  <1358432538.29723.8.camel@edumazet-glaptop> <1358436367.29723.49.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Or Gerlitz" <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:47183 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752039Ab3ATOrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 09:47:49 -0500
In-Reply-To: <1358436367.29723.49.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/01/2013 17:26, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> remove redundant code from build_inline_wqe()
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> Amir, reviewing this driver, it looks like following could be done,
> could you test the patch for me ?
>
> Thanks
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index 2b799f4..16af338 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -515,10 +515,6 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
>   		wmb();
>   		inl->byte_count = cpu_to_be32(1 << 31 | (skb->len - spc));
>   	}
> -	tx_desc->ctrl.vlan_tag = cpu_to_be16(*vlan_tag);
> -	tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN *
> -		(!!vlan_tx_tag_present(skb));
> -	tx_desc->ctrl.fence_size = (real_size / 16) & 0x3f;
>   }
>
>   u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
>
>
Acked-By: Amir Vadai <amirv@mellanox.com>
