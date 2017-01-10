From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] mlx4: Return EOPNOTSUPP instead of ENOTSUPP
Date: Tue, 10 Jan 2017 15:43:39 +0300
Message-ID: <2e26d5f0-fed8-a2b9-392a-87da29c38758@cogentembedded.com>
References: <1484000039-671014-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:34579 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754604AbdAJMnn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 07:43:43 -0500
Received: by mail-lf0-f43.google.com with SMTP id v186so60383151lfa.1
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 04:43:43 -0800 (PST)
In-Reply-To: <1484000039-671014-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 01/10/2017 01:13 AM, Martin KaFai Lau wrote:

> In commit b45f0674b997 ("mlx4: xdp: Allow raising MTU up to one page minus eth and vlan hdrs"),
> it changed ENOTSUPP to EOPNOTSUPP by mistake.  This patch fixes it.

    You mean vice versa (looking at your patch)?

> Fixes: b45f0674b997 ("mlx4: xdp: Allow raising MTU up to one page minus eth and vlan hdrs")
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index edbe200ac2fa..4910d9af1933 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -2277,7 +2277,7 @@ static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
>
>  	if (priv->tx_ring_num[TX_XDP] &&
>  	    !mlx4_en_check_xdp_mtu(dev, new_mtu))
> -		return -ENOTSUPP;
> +		return -EOPNOTSUPP;
>
>  	dev->mtu = new_mtu;
>

MBR, Sergei
