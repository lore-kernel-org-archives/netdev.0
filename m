From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next 0/2] mlx4 XDP TX refactor
Date: Sun, 30 Oct 2016 18:21:26 +0200
Message-ID: <0773c58c-293d-38be-9844-e8f92d135aec@gmail.com>
References: <1477579924-32737-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34614 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755273AbcJ3QV3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 12:21:29 -0400
Received: by mail-wm0-f65.google.com with SMTP id p190so8787608wmp.1
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2016 09:21:28 -0700 (PDT)
In-Reply-To: <1477579924-32737-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series makes Brenden's fix unneeded:
958b3d396d7f ("net/mlx4_en: fixup xdp tx irq to match rx")

The fix got into net, but yet to be in net-next.

Should I wait with this series and send a re-spin, with a revert of the 
fix, once it gets into net-next?

Regards,
Tariq


On 27/10/2016 5:52 PM, Tariq Toukan wrote:
> Hi Dave,
>
> This patchset refactors the XDP forwarding case, so that
> its dedicated transmit queues are managed in a complete
> separation from the other regular ones.
>
> Series generated against net-next commit:
> 6edf10173a1f "devlink: Prevent port_type_set() callback when it's not needed"
>
> Thanks,
> Tariq.
>
> Tariq Toukan (2):
>    net/mlx4_en: Add TX_XDP for CQ types
>    net/mlx4_en: Refactor the XDP forwarding rings scheme
>
>   drivers/net/ethernet/mellanox/mlx4/en_cq.c      |  18 +-
>   drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  76 +++--
>   drivers/net/ethernet/mellanox/mlx4/en_main.c    |   2 +-
>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 378 ++++++++++++++----------
>   drivers/net/ethernet/mellanox/mlx4/en_port.c    |   4 +-
>   drivers/net/ethernet/mellanox/mlx4/en_rx.c      |   8 +-
>   drivers/net/ethernet/mellanox/mlx4/en_tx.c      |   9 +-
>   drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  18 +-
>   8 files changed, 305 insertions(+), 208 deletions(-)
>
