From: Wei-Chun Chao <weichunc@plumgrid.com>
Subject: Re: [PATCH net-next 0/2] net/mlx4: Add support for TCP/IP offloads of
 vxlan tunneling
Date: Wed, 18 Dec 2013 17:16:32 -0800
Message-ID: <CACviX4G9vbHLWm3gu-S+SUSiSoawmQKAeXhRm9hZz1a7Hn=LiQ@mail.gmail.com>
References: <1387375528-2337-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem <davem@davemloft.net>, netdev <netdev@vger.kernel.org>,
	amirv@mellanox.com, yanb@mellanox.com,
	Alexei Starovoitov <ast@plumgrid.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f52.google.com ([209.85.212.52]:35198 "EHLO
	mail-vb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328Ab3LSBQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 20:16:33 -0500
Received: by mail-vb0-f52.google.com with SMTP id p5so256033vbn.25
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 17:16:32 -0800 (PST)
In-Reply-To: <1387375528-2337-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Or,
I tested this patch and with vxlan offload off I saw 14.x Gbps max and
with offload on I saw 24Gbps (16 and 32 threads got the same number
and 8 RSS rings in use).

Thanks,
Weichun

On Wed, Dec 18, 2013 at 6:05 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> Hi Dave,
>
> These two patches add mlx4 support for TCP/IP offloads under vxlan tunneling
>
> The patches are againt net-next commit 7ed2a0d "Merge branch 'for-davem'
> of git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next" plus the in-progress
> mlx4 series http://marc.info/?l=linux-netdev&m=138726378426919&w=2 -- the two
> patch series pretty much touch different areas and practically can be applied in any order.
>
> Or.
>
> Or Gerlitz (2):
>   net/mlx4_core: Add basic support for TCP/IP offloads under tunneling
>   net/mlx4_en: Add netdev support for TCP/IP offloads of vxlan tunneling
>
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |   95 +++++++++++++++++++++
>  drivers/net/ethernet/mellanox/mlx4/en_resources.c |    6 ++
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c        |   15 +++-
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c        |   14 +++-
>  drivers/net/ethernet/mellanox/mlx4/fw.c           |   19 ++++-
>  drivers/net/ethernet/mellanox/mlx4/main.c         |   14 +++
>  drivers/net/ethernet/mellanox/mlx4/mcg.c          |   14 +++-
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |    3 +-
>  drivers/net/ethernet/mellanox/mlx4/port.c         |   41 +++++++++
>  include/linux/mlx4/cmd.h                          |    1 +
>  include/linux/mlx4/cq.h                           |    5 +
>  include/linux/mlx4/device.h                       |   37 ++++++++-
>  include/linux/mlx4/qp.h                           |    6 ++
>  13 files changed, 263 insertions(+), 7 deletions(-)
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
