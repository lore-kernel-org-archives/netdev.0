From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH v4 net-next 11/13] mlx4: factorize page_address() calls
Date: Thu, 9 Mar 2017 15:57:13 +0200
Message-ID: <d4104602-b5d2-423f-bfeb-3438342486d7@mellanox.com>
References: <20170308161718.2867-1-edumazet@google.com>
 <20170308161718.2867-12-edumazet@google.com>
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
Received: from mail-he1eur01on0046.outbound.protection.outlook.com ([104.47.0.46]:56288
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753918AbdCIOMt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 09:12:49 -0500
In-Reply-To: <20170308161718.2867-12-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/03/2017 6:17 PM, Eric Dumazet wrote:
> We need to compute the frame virtual address at different points.
> Do it once.
>
> Following patch will use the new va address for validate_loopback()
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c | 15 +++++++--------
>  1 file changed, 7 insertions(+), 8 deletions(-)
>
Acked-by: Tariq Toukan <tariqt@mellanox.com>

Thanks.
