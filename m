From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH v4 net-next 01/13] mlx4: dma_dir is a mlx4_en_priv
 attribute
Date: Thu, 9 Mar 2017 15:52:56 +0200
Message-ID: <030558e2-8267-f231-ff49-bc276fe4b11b@mellanox.com>
References: <20170308161718.2867-1-edumazet@google.com>
 <20170308161718.2867-2-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        "Saeed Mahameed" <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        "Jesper Dangaard Brouer" <brouer@redhat.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50053.outbound.protection.outlook.com ([40.107.5.53]:21545
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754648AbdCIO2J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 09:28:09 -0500
In-Reply-To: <20170308161718.2867-2-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/03/2017 6:17 PM, Eric Dumazet wrote:
> No need to duplicate it for all queues and frags.
>
> num_frags & log_rx_info become u8 to save space.
> u8 accesses are a bit faster than u16 anyway.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 16 ++++++++--------
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c   |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  6 +++---
>  3 files changed, 12 insertions(+), 12 deletions(-)
>

Acked-by: Tariq Toukan <tariqt@mellanox.com>

Thanks.
