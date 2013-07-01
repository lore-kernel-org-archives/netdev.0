From: Roland Dreier <roland@kernel.org>
Subject: Re: [PATCH for-next 0/8] Add Mellanox mlx5 driver for Connect-IB devices
Date: Mon, 1 Jul 2013 14:20:44 -0700
Message-ID: <CAL1RGDVgSucpRhyxBZDVeLO+Q+Y7HuPsDjUy6kaFMoL3E8s77g@mail.gmail.com>
References: <1371384149-24558-1-git-send-email-eli@dev.mellanox.co.il>
 <CAJZOPZ+NQa3CWnw3rZQh2UuwdrNhiwtVSyuk9D9YtwfQQ9e1XA@mail.gmail.com>
 <CAJZOPZKLb9k1xXkTnrtzYKpwrSJDQgBpONUVCp3et36JeaEi-Q@mail.gmail.com>
 <CAL1RGDX5mHj5oVqFhQ4Ssr25jpL4rV2Tv=zXvLOZfwupJ0gqJw@mail.gmail.com>
 <1372701839.2481.3.camel@joe-AO722> <CAL1RGDW_Z06ZqpOhz3tAkKn=rpLEZE6hWZkLNd9OQgCbrX6YAg@mail.gmail.com>
 <1372709942.2481.13.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Eli Cohen <eli@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog105.obsmtp.com ([74.125.245.78]:42048 "HELO
	na3sys010aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754828Ab3GAVVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 17:21:08 -0400
Received: by mail-lb0-f176.google.com with SMTP id z5so2821616lbh.35
        for <netdev@vger.kernel.org>; Mon, 01 Jul 2013 14:21:05 -0700 (PDT)
In-Reply-To: <1372709942.2481.13.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 1, 2013 at 1:19 PM, Joe Perches <joe@perches.com> wrote:
> I think these are the groupings.
>
> +enum {
> +       MLX5_MOD_MAIN,
> +       MLX5_MOD_CMDIF,
> +       MLX5_MOD_EQ,
> +       MLX5_MOD_QP,
> +       MLX5_MOD_PGALLOC,
> +       MLX5_MOD_FW,
> +       MLX5_MOD_UAR,
> +       MLX5_MOD_ALLOC,
> +       MLX5_MOD_DEBUG,
> +       MLX5_MOD_HEALTH,
> +       MLX5_MOD_MAD,
> +       MLX5_MOD_MCG,
> +       MLX5_MOD_MR,
> +       MLX5_MOD_PD,
> +       MLX5_MOD_PORT,
> +       MLX5_MOD_SRQ,
> +       MLX5_MOD_CQ,
> +       MLX5_MOD_CMD_DATA, /* print command payload only */
> +       MLX5_CMD_DATA_TIME,
> +};


Right, but then look how they're used.  For example,
drivers/net/ethernet/mellanox/mlx5/core/main.c has:

    MLX5_MOD_DBG_MASK(MLX5_MOD_MAIN);

so MLX5_MOD_MAIN just means messages in main.c, etc.

 - R.
