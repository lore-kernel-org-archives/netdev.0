From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next v3 3/4] bpf, mlx5: drop priv->xdp_prog reference
 on netdev cleanup
Date: Mon, 21 Nov 2016 11:31:24 +0200
Message-ID: <CALzJLG-7icaCU-cOTZoKtm5H6Ns=Vwa=wFw8Y-LkQ3zQWUea4w@mail.gmail.com>
References: <cover.1479514784.git.daniel@iogearbox.net> <29469b54bfddfe218266b8b902a3735034d28226.1479514784.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Zhiyi Sun <zhiyisun@gmail.com>,
        Rana Shahout <ranas@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36208 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752266AbcKUJbp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 04:31:45 -0500
Received: by mail-qk0-f196.google.com with SMTP id h201so45252744qke.3
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 01:31:45 -0800 (PST)
In-Reply-To: <29469b54bfddfe218266b8b902a3735034d28226.1479514784.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 19, 2016 at 2:45 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> mlx5e_xdp_set() is currently the only place where we drop reference on the
> prog sitting in priv->xdp_prog when it's exchanged by a new one. We also
> need to make sure that we eventually release that reference, for example,
> in case the netdev is dismantled, otherwise we leak the program.
>
> Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Saeed Mahameed <saeedm@mellanox.com>
