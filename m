From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 6/9] net/mlx4_en: Adding support of turning off
 link autonegotiation via ethtool
Date: Mon, 16 Jan 2017 23:48:18 +0200
Message-ID: <CAJ3xEMjEPQv=Agz5Wr-2UEL+iv7nz4NAcpCKY9=C4vs6SfKLLA@mail.gmail.com>
References: <1484587805-12666-1-git-send-email-tariqt@mellanox.com> <1484587805-12666-7-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>,
        Ariel Levkovich <lariel@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35589 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751238AbdAPVsT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 16:48:19 -0500
Received: by mail-oi0-f67.google.com with SMTP id x84so13582024oix.2
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 13:48:19 -0800 (PST)
In-Reply-To: <1484587805-12666-7-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 16, 2017 at 7:30 PM, Tariq Toukan <tariqt@mellanox.com> wrote:
0644
> --- a/include/linux/mlx4/device.h
> +++ b/include/linux/mlx4/device.h
> @@ -1539,8 +1539,13 @@ enum mlx4_ptys_proto {
>         MLX4_PTYS_EN = 1<<2,
>  };
>
> +enum mlx4_ptys_flags {
> +       MLX4_PTYS_AN_DISABLE_CAP   = 1 << 5,
> +       MLX4_PTYS_AN_DISABLE_ADMIN = 1 << 6,
> +};
> +
>  struct mlx4_ptys_reg {
> -       u8 resrvd1;
> +       u8 flags;
>         u8 local_port;
>         u8 resrvd2;
>         u8 proto_mask;

Hi Ariel,

I didn't see any new dev cap bit, what happens with FW version which
don't support this, is the result well defined? what is it?

Or.
