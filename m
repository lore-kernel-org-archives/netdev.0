From: Amir Vadai <amirv@mellanox.com>
Subject: Re: net/mlx4_en: call gro handler for encapsulated frames
Date: Sun, 12 Jan 2014 14:43:26 +0200
Message-ID: <20140112124322.GA13243@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <1389292213.31367.49.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jerry Chu <hkchu@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:60456 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbaALMnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 07:43:32 -0500
Received: by mail-ea0-f175.google.com with SMTP id z10so2827828ead.34
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 04:43:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1389292213.31367.49.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/14 10:30 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> In order to use the native GRO handling of encapsulated protocols on
> mlx4, we need to call napi_gro_receive() instead of netif_receive_skb()
> unless busy polling is in action.
> 
> While we are at it, rename mlx4_en_cq_ll_polling() to
> mlx4_en_cq_busy_polling()
> 
> Tested with GRE tunnel : GRO aggregation is now performed on the
> ethernet device instead of being done later on gre device.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Amir Vadai <amirv@mellanox.com>
> Cc: Jerry Chu <hkchu@google.com>
> Cc: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c   |    8 +++++---
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    4 ++--
>  2 files changed, 7 insertions(+), 5 deletions(-)
> 

Acked-By: Amir Vadai <amirv@mellanox.com>
