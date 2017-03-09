From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH v4 net-next 06/13] mlx4: removal of frag_sizes[]
Date: Thu, 9 Mar 2017 15:55:12 +0200
Message-ID: <30420025-69c8-10a3-f300-857221f1f1e0@mellanox.com>
References: <20170308161718.2867-1-edumazet@google.com>
 <20170308161718.2867-7-edumazet@google.com>
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
Received: from mail-db5eur01on0059.outbound.protection.outlook.com ([104.47.2.59]:8140
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754526AbdCINz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 08:55:26 -0500
In-Reply-To: <20170308161718.2867-7-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/03/2017 6:17 PM, Eric Dumazet wrote:
> We will soon use order-0 pages, and frag truesize will more precisely
> match real sizes.
>
> In the new model, we prefer to use <= 2048 bytes fragments, so that
> we can use page-recycle technique on PAGE_SIZE=4096 arches.
>
> We will still pack as much frames as possible on arches with big
> pages, like PowerPC.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 24 ++++++++++--------------
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  8 --------
>  2 files changed, 10 insertions(+), 22 deletions(-)
>
Acked-by: Tariq Toukan <tariqt@mellanox.com>

Thanks.
