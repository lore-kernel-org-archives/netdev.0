From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH v4 net-next 09/13] mlx4: add rx_alloc_pages counter in
 ethtool -S
Date: Thu, 9 Mar 2017 15:56:31 +0200
Message-ID: <8f748b9e-8875-e562-94a4-bd1871c3e068@mellanox.com>
References: <20170308161718.2867-1-edumazet@google.com>
 <20170308161718.2867-10-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0041.outbound.protection.outlook.com ([104.47.1.41]:11979
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754086AbdCIN4k (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 08:56:40 -0500
In-Reply-To: <20170308161718.2867-10-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/03/2017 6:17 PM, Eric Dumazet wrote:
> This new counter tracks number of pages that we allocated for one port.
>
> lpaa24:~# ethtool -S eth0 | egrep 'rx_alloc_pages|rx_packets'
>      rx_packets: 306755183
>      rx_alloc_pages: 932897
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/en_port.c    |  2 ++
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c      | 11 +++++++----
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  1 +
>  drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h |  2 +-
>  5 files changed, 12 insertions(+), 6 deletions(-)
>
Acked-by: Tariq Toukan <tariqt@mellanox.com>

Thanks.
