From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH v4 net-next 03/13] mlx4: get rid of frag_prefix_size
Date: Thu, 9 Mar 2017 15:53:56 +0200
Message-ID: <2e4eeb31-8d64-4fc9-9730-16eec49dccfb@mellanox.com>
References: <20170308161718.2867-1-edumazet@google.com>
 <20170308161718.2867-4-edumazet@google.com>
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
Received: from mail-eopbgr50058.outbound.protection.outlook.com ([40.107.5.58]:34287
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753861AbdCINyW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 08:54:22 -0500
In-Reply-To: <20170308161718.2867-4-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/03/2017 6:17 PM, Eric Dumazet wrote:
> Using per frag storage for frag_prefix_size is really silly.
>
> mlx4_en_complete_rx_desc() has all needed info already.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 27 ++++++++++++---------------
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  3 +--
>  2 files changed, 13 insertions(+), 17 deletions(-)
>
Acked-by: Tariq Toukan <tariqt@mellanox.com>

Thanks.
