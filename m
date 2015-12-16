From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 2/2] net/mlx5_en: Add HW timestamping (TS) support
Date: Wed, 16 Dec 2015 23:38:50 +0200
Message-ID: <CAJ3xEMjR=3t42BmHkp_Y2SsqpA0XRxrChj0_C8bQA_8uTu2swA@mail.gmail.com>
References: <1450284394-32386-1-git-send-email-saeedm@mellanox.com>
	<1450284394-32386-3-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Tal Alon <talal@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:34831 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966489AbbLPViv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 16:38:51 -0500
Received: by mail-ig0-f181.google.com with SMTP id to4so85287463igc.0
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 13:38:50 -0800 (PST)
In-Reply-To: <1450284394-32386-3-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2015 at 6:46 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> From: Eran Ben Elisha <eranbe@mellanox.com>
>
> Add support for enable/disable HW timestamping [..]

>  drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |    1 +
>  drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    2 +-
>  drivers/net/ethernet/mellanox/mlx5/core/en.h       |   25 +++
>  drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |  226 ++++++++++++++++++++
>  .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   32 +++
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  103 +++++++++-
>  drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |    9 +
>  drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   14 ++
>  .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |    1 +

On top of Richard's comment, lets shrink this a bit more -- put the
below changes into a pure mlx5_core downstream patch

>  drivers/net/ethernet/mellanox/mlx5/core/main.c     |   31 +++
>  include/linux/mlx5/device.h                        |   20 ++-
>  include/linux/mlx5/mlx5_ifc.h                      |    5 +-


>  12 files changed, 462 insertions(+), 7 deletions(-)
