From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next 0/4] net: sched: get rid of cls_flower->egress_dev
Date: Tue, 10 Oct 2017 20:25:02 +0300
Message-ID: <CAJ3xEMid7eDVe6RQBs4qCNm-_DsRLZM=TDLO_YTCmdbmJqX6KQ@mail.gmail.com>
References: <20171010073016.3682-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        mlxsw <mlxsw@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35952 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756600AbdJJRZE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 13:25:04 -0400
Received: by mail-oi0-f65.google.com with SMTP id s185so6989967oif.3
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 10:25:04 -0700 (PDT)
In-Reply-To: <20171010073016.3682-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 10:30 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>
>
>  drivers/net/ethernet/mellanox/mlx5/core/en.h      |   3 +
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   4 +-
>  drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  |  31 ++--



Jiri,

FWIW, as I reported to you earlier, I was playing with tc encap/decap
rules on 4.14-rc+ (net) before
applying any patch of this series, and something is messy w.r.t to
decap rules. I don't see
them removed at all when user space attempts to do so. It might
(probably) mlx5 bug, which
we will have to fix for net and later rebase net-next over net. We
have short WW here so
I will not be able to do RCA this week.
