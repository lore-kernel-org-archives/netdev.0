From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net] net/mlx5e: Do not recycle pages from emergency reserve
Date: Fri, 20 Jan 2017 12:28:00 +0200
Message-ID: <CALzJLG_JcOzW0EDm54pKX=uhNbA9CSAbcWCR4-r7C=y6C0nBsQ@mail.gmail.com>
References: <1484809388.16328.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f178.google.com ([209.85.161.178]:33597 "EHLO
        mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751813AbdATKfu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 05:35:50 -0500
Received: by mail-yw0-f178.google.com with SMTP id u68so41361177ywg.0
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 02:35:50 -0800 (PST)
In-Reply-To: <1484809388.16328.19.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 19, 2017 at 9:03 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> A driver using dev_alloc_page() must not reuse a page allocated from
> emergency memory reserve.
>
> Otherwise all packets using this page will be immediately dropped,
> unless for very specific sockets having SOCK_MEMALLOC bit set.
>
> This issue might be hard to debug, because only a fraction of received
> packets would be dropped.
>
> Fixes: 4415a0319f92 ("net/mlx5e: Implement RX mapped page cache for page recycle")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> Cc: Saeed Mahameed <saeedm@mellanox.com>

Acked-by: Saeed Mahameed <saeedm@mellanox.com>
