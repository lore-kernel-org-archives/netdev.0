From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net] mlx4: fix potential divide by 0 in mlx4_en_auto_moderation()
Date: Mon, 20 Feb 2017 00:21:19 +0200
Message-ID: <CALzJLG8FSEz67qRxzqp9DT5AF=RkS-5HqdaQGKwQmuuNWjs0Ew@mail.gmail.com>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG9HWiNfGaWF_uB6F0BttPbzc_eSpow_zv7FwiK3GWoYQA@mail.gmail.com>
 <1487165355.1311.2.camel@edumazet-glaptop3.roam.corp.google.com>
 <1487167443.1311.8.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8WHJYQFEsxU39jgpMDFHPkHuDX6VU7vOcd+wqBedonfA@mail.gmail.com>
 <1487260187.1311.53.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG_w2m9p3OQxi9c9=Y-RVKKLyce1b-WjoSvLUVGcWHNwYA@mail.gmail.com>
 <1487286833.1311.63.camel@edumazet-glaptop3.roam.corp.google.com> <1487287407.1311.69.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>, jackm@mellanox.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:35085 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751307AbdBSWVk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 17:21:40 -0500
Received: by mail-qk0-f173.google.com with SMTP id u188so6391582qkc.2
        for <netdev@vger.kernel.org>; Sun, 19 Feb 2017 14:21:40 -0800 (PST)
In-Reply-To: <1487287407.1311.69.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 17, 2017 at 1:23 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> 1) In the case where rate == priv->pkt_rate_low == priv->pkt_rate_high,
> mlx4_en_auto_moderation() does a divide by zero.
>
> 2) We want to properly change the moderation parameters if rx_frames
> was changed (like in ethtool -C eth0 rx-frames 16)
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
