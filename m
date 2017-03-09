From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH v4 net-next 04/13] mlx4: rx_headroom is a per port
 attribute
Date: Thu, 9 Mar 2017 15:54:28 +0200
Message-ID: <df34d000-501d-b2c9-d0e9-9f8e85a449e5@mellanox.com>
References: <20170308161718.2867-1-edumazet@google.com>
 <20170308161718.2867-5-edumazet@google.com>
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
Received: from mail-db5eur01on0084.outbound.protection.outlook.com ([104.47.2.84]:31568
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754526AbdCINzF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 08:55:05 -0500
In-Reply-To: <20170308161718.2867-5-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/03/2017 6:17 PM, Eric Dumazet wrote:
> No need to duplicate it per RX queue / frags.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 6 +++---
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h | 2 +-
>  2 files changed, 4 insertions(+), 4 deletions(-)
>
Acked-by: Tariq Toukan <tariqt@mellanox.com>

Thanks.
