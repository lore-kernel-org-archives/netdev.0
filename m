From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH v4 net-next 10/13] mlx4: do not access rx_desc from
 mlx4_en_process_rx_cq()
Date: Thu, 9 Mar 2017 15:56:54 +0200
Message-ID: <c64c3086-baab-3f1b-266a-4a4533e0c271@mellanox.com>
References: <20170308161718.2867-1-edumazet@google.com>
 <20170308161718.2867-11-edumazet@google.com>
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
Received: from mail-ve1eur01on0061.outbound.protection.outlook.com ([104.47.1.61]:39705
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754618AbdCIN5C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 08:57:02 -0500
In-Reply-To: <20170308161718.2867-11-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/03/2017 6:17 PM, Eric Dumazet wrote:
> Instead of fetching dma address from rx_desc->data[0].addr,
> prefer using frags[0].dma + frags[0].page_offset to avoid
> a potential cache line miss.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c | 9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
>
Acked-by: Tariq Toukan <tariqt@mellanox.com>

Thanks.
