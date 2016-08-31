From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 3/6] net/mlx5: Add DCBX firmware commands support
Date: Wed, 31 Aug 2016 19:08:46 +0300
Message-ID: <CALzJLG_=-JG92f4kf4YTbpqp7PUN7LRXcnBAPV9jcA5HAK5Nrw@mail.gmail.com>
References: <1472556595-9286-1-git-send-email-saeedm@mellanox.com>
 <1472556595-9286-4-git-send-email-saeedm@mellanox.com> <CAD=hENcMF98xDQ-vjg3+txEGsFSzh32ZaPtoU9+gpL6aJMoEag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Huy Nguyen <huyn@mellanox.com>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:34684 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934855AbcHaQJI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 12:09:08 -0400
Received: by mail-lf0-f67.google.com with SMTP id k135so2674528lfb.1
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 09:09:07 -0700 (PDT)
In-Reply-To: <CAD=hENcMF98xDQ-vjg3+txEGsFSzh32ZaPtoU9+gpL6aJMoEag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 31, 2016 at 2:24 PM, zhuyj <zyjzyj2000@gmail.com> wrote:
> +       u32 in[MLX5_ST_SZ_DW(dcbx_param)];
> +
> +       memset(in, 0, sizeof(in));
>
> can we replace the above with "u32 in[MLX5_ST_SZ_DW(dcbx_param)] = {0};"?

yes, we will change it in V2.

Thanks.
