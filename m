From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net 3/6] net/mlx5e: Do not reduce LRO WQE size when not
 using build_skb
Date: Wed, 22 Feb 2017 11:45:58 -0800
Message-ID: <CAADnVQKVj3MbjkstfcCsUy7DmqLGUtrq5=g=Bzd1u=bymcuVuQ@mail.gmail.com>
References: <20170222152016.31263-1-saeedm@mellanox.com> <20170222152016.31263-4-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:36780 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753449AbdBVTqW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 14:46:22 -0500
Received: by mail-wr0-f180.google.com with SMTP id 89so9371903wrr.3
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 11:46:21 -0800 (PST)
In-Reply-To: <20170222152016.31263-4-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 22, 2017 at 7:20 AM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> From: Tariq Toukan <tariqt@mellanox.com>
>
> When rq_type is Striding RQ, no room of SKB_RESERVE is needed
> as SKB allocation is not done via build_skb.
>
> Fixes: e4b85508072b ("net/mlx5e: Slightly reduce hardware LRO size")
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>

why this one is a bug fix?
Sound like an optimization from commit log.
