From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 2/2] net/mlx5_en: Add HW timestamping (TS) support
Date: Wed, 16 Dec 2015 23:41:24 +0200
Message-ID: <CAJ3xEMjGqAre+EOytoqQWRL=HdcU1rGkfEJuDJuWGqJ1PtmDiQ@mail.gmail.com>
References: <1450284394-32386-1-git-send-email-saeedm@mellanox.com>
	<1450284394-32386-3-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:36973 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966040AbbLPVlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 16:41:24 -0500
Received: by mail-ig0-f181.google.com with SMTP id to18so68152346igc.0
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 13:41:24 -0800 (PST)
In-Reply-To: <1450284394-32386-3-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2015 at 6:46 PM, Saeed Mahameed <saeedm@mellanox.com>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
> index ea6a137..b6651b8 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
> @@ -98,6 +98,7 @@ int mlx5_core_sriov_configure(struct pci_dev *dev, int num_vfs);
>  int mlx5_core_enable_hca(struct mlx5_core_dev *dev, u16 func_id);
>  int mlx5_core_disable_hca(struct mlx5_core_dev *dev, u16 func_id);
>  int mlx5_wait_for_vf_pages(struct mlx5_core_dev *dev);
> +cycle_t mlx5_core_read_clock(struct mlx5_core_dev *dev);
>
>  void mlx5e_init(void);
>  void mlx5e_cleanup(void);

this should go too into the pre-patch
