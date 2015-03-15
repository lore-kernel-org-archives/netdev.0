From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next V2 0/3] Add max rate TXQ attribute
Date: Sun, 15 Mar 2015 10:08:08 -0700
Message-ID: <CALx6S37qzKSJ8cWiCDmfHM=bRy67jup4YriMkL6tw9BUXCRi5Q@mail.gmail.com>
References: <1426424596-3911-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:33445 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467AbbCORIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 13:08:09 -0400
Received: by iecvj10 with SMTP id vj10so149858695iec.0
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 10:08:08 -0700 (PDT)
In-Reply-To: <1426424596-3911-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 15, 2015 at 6:03 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> Add the ability to set a max-rate limitation for TX queues.
> The attribute name is maxrate and the units are Mbs, to make
> it similar to the existing max-rate limitation knobs (ETS and
> SRIOV ndo calls).
>
Guaranteed rate is often defined in conjunction with maximum rate. It
might be nice to add a parameter for that to the ndo function in
anticipation of someone supporting that also.

Thanks,
Tom


> Or.
>
> changes from V1:
>   - addressed feedback from Dave
>
> changes from V0:
>   - addressed feedback from Sergei
>
>
>
> John Fastabend (1):
>   net: Add max rate tx queue attribute
>
> Or Gerlitz (2):
>   net/mlx4_core: Add basic support for QP max-rate limiting
>   net/mlx4_en: Add tx queue maxrate support
>
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   29 +++++++++
>  drivers/net/ethernet/mellanox/mlx4/fw.c            |   33 +++++++++-
>  drivers/net/ethernet/mellanox/mlx4/fw.h            |    1 +
>  drivers/net/ethernet/mellanox/mlx4/main.c          |    2 +
>  drivers/net/ethernet/mellanox/mlx4/qp.c            |    5 ++
>  .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    6 ++-
>  include/linux/mlx4/device.h                        |   17 +++++
>  include/linux/mlx4/qp.h                            |   14 +++-
>  include/linux/netdevice.h                          |    9 +++
>  net/core/net-sysfs.c                               |   67 ++++++++++++++++----
>  10 files changed, 165 insertions(+), 18 deletions(-)
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
