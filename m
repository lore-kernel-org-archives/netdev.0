From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH v4 net-next 08/13] mlx4: add page recycling in receive
 path
Date: Thu, 9 Mar 2017 15:56:09 +0200
Message-ID: <a1af858c-694e-f0e4-22fa-d6f0ece93052@mellanox.com>
References: <20170308161718.2867-1-edumazet@google.com>
 <20170308161718.2867-9-edumazet@google.com>
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
Received: from mail-he1eur01on0050.outbound.protection.outlook.com ([104.47.0.50]:4971
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754776AbdCIN4W (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 08:56:22 -0500
In-Reply-To: <20170308161718.2867-9-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/03/2017 6:17 PM, Eric Dumazet wrote:
> Same technique than some Intel drivers, for arches where PAGE_SIZE = 4096
>
> In most cases, pages are reused because they were consumed
> before we could loop around the RX ring.
>
> This brings back performance, and is even better,
> a single TCP flow reaches 30Gbit on my hosts.
>
> v2: added full memset() in mlx4_en_free_frag(), as Tariq found it was needed
> if we switch to large MTU, as priv->log_rx_info can dynamically be changed.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 258 +++++++++------------------
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |   1 -
>  2 files changed, 82 insertions(+), 177 deletions(-)
>
Acked-by: Tariq Toukan <tariqt@mellanox.com>

Thanks.
