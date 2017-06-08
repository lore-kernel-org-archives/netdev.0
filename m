From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH RFC net-next 1/4] net/mlx5e: Rearrange netdevice ops structures
Date: Thu, 8 Jun 2017 10:52:41 +0300
Message-ID: <CAJ3xEMj7YOatHvRUj_AmEfVPGuV_7tgOVqy2+scieFuRhfT7TA@mail.gmail.com>
References: <20170607234214.24723-1-saeedm@mellanox.com> <20170607234214.24723-2-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Jes Sorensen <jsorensen@fb.com>,
        Kernel Team <kernel-team@fb.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Tzahi Oved <tzahio@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f177.google.com ([74.125.82.177]:35285 "EHLO
        mail-ot0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751464AbdFHHwm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 03:52:42 -0400
Received: by mail-ot0-f177.google.com with SMTP id a2so19222031oth.2
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 00:52:42 -0700 (PDT)
In-Reply-To: <20170607234214.24723-2-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 8, 2017 at 2:42 AM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> Since we are going to allow compiling the driver without eswitch,
> it means we will have to compile out mlx5e_netdev_ops_sriov and will
> replace it with mlx5e_netdev_ops_basic.
>
> Move missing vxlan ndos into mlx5e_netdev_ops_basic.

preferred to be more price and use the term udp tunnel (missing udp tunnel) ndos

> Rearrange some ndos in mlx5e_netdev_ops_sriov and put vf/eswitch related
> ndos towards the end of the struct.

Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
