From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH v4 net-next 12/13] mlx4: make validate_loopback() more
 generic
Date: Thu, 9 Mar 2017 15:57:34 +0200
Message-ID: <54d43d80-5e07-19b2-4bd5-cfe22dc4033e@mellanox.com>
References: <20170308161718.2867-1-edumazet@google.com>
 <20170308161718.2867-13-edumazet@google.com>
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
Received: from mail-eopbgr30046.outbound.protection.outlook.com ([40.107.3.46]:43904
        "EHLO EUR03-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753918AbdCIOPH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 09:15:07 -0500
In-Reply-To: <20170308161718.2867-13-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/03/2017 6:17 PM, Eric Dumazet wrote:
> Testing a boolean in fast path is not worth duplicating
> the code allocating packets, when GRO is on or off.
>
> If this proves to be a problem, we might later use a jump label.
>
> Next patch will remove this duplicated code and ease code review.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c       | 23 ++++++++++-------------
>  drivers/net/ethernet/mellanox/mlx4/en_selftest.c |  6 ------
>  2 files changed, 10 insertions(+), 19 deletions(-)
>
Acked-by: Tariq Toukan <tariqt@mellanox.com>

Thanks.
