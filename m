From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net/mlx5e: remove napi_hash_del() calls
Date: Wed, 16 Nov 2016 06:20:29 -0800
Message-ID: <1479306029.8455.180.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1479304537.8455.167.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36098 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752968AbcKPOUb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:20:31 -0500
Received: by mail-pg0-f66.google.com with SMTP id x23so14839789pgx.3
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:20:31 -0800 (PST)
In-Reply-To: <1479304537.8455.167.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-16 at 05:55 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Calling napi_hash_del() after netif_napi_del() is pointless.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    4 ----
>  1 file changed, 4 deletions(-)


Hmmm... missing body. Will send a v2.
