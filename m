From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 6/6] net/mlx5: Add handling for port module event
Date: Tue, 30 Aug 2016 23:24:30 +0300
Message-ID: <CAJ3xEMg9d58BwLR3QAK_WjmLM1Sz2RrCDUJxQbeLzPAW7Hwp2Q@mail.gmail.com>
References: <1472556595-9286-1-git-send-email-saeedm@mellanox.com> <1472556595-9286-7-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Huy Nguyen <huyn@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35452 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752388AbcH3UYg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 16:24:36 -0400
Received: by mail-oi0-f68.google.com with SMTP id e80so2796160oig.2
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 13:24:31 -0700 (PDT)
In-Reply-To: <1472556595-9286-7-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 30, 2016 at 2:29 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> From: Huy Nguyen <huyn@mellanox.com>

> +++ b/include/linux/mlx5/device.h
> @@ -543,6 +544,15 @@ struct mlx5_eqe_vport_change {
>         __be32          rsvd1[6];
>  } __packed;
>
> +struct mlx5_eqe_port_module {
> +       u8        rsvd0[1];
> +       u8        module;
> +       u8        rsvd1[1];
> +       u8        module_status;
> +       u8        rsvd2[2];
> +       u8        error_type;
> +};
> +

Saeed, any reason for this struct and friends not to be  @ the FW IFC file?
