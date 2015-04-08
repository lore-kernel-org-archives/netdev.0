From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 11/11] net/mlx5: Ethernet driver
Date: Wed, 08 Apr 2015 08:57:31 -0700
Message-ID: <1428508651.25985.221.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1428504685-8945-1-git-send-email-amirv@mellanox.com>
	 <1428504685-8945-12-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:35356 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560AbbDHP5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 11:57:34 -0400
Received: by iggg4 with SMTP id g4so43502665igg.0
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 08:57:33 -0700 (PDT)
In-Reply-To: <1428504685-8945-12-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-08 at 17:51 +0300, Amir Vadai wrote:

> +
> +static u32 ptys2ethtool_supported_link(u32 eth_proto_cap)
> +{
> +	int i;
> +	u32 supoprted_modes = 0;
> +
> +	for (i = 0; i < MLX5E_LINK_MODES_NUMBER; ++i) {
> +		if (eth_proto_cap & MLX5E_PROT_MASK(i))
> +			supoprted_modes |= ptys2ethtool_table[i].supported;
> +	}
> +	return supoprted_modes;
> +}

Small nit 
typo :  -> supported_modes 
