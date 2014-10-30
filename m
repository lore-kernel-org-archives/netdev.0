From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next] mlx4: use napi_schedule_irqoff()
Date: Thu, 30 Oct 2014 09:30:10 +0200
Message-ID: <5451E902.5090003@mellanox.com>
References: <1414626885.631.102.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:43839 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751388AbaJ3HaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 03:30:16 -0400
In-Reply-To: <1414626885.631.102.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/2014 1:54 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> mlx4_en_rx_irq() and mlx4_en_tx_irq() run from hard interrupt context.
> 
> They can use napi_schedule_irqoff() instead of napi_schedule()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c |    4 ++--
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c |    4 ++--
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 

Acked-By: Amir Vadai <amirv@mellanox.com>

Thanks,
Amir
