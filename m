From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 00/10] Mellanox 100G mlx5 DCBX and ethtool updates
Date: Sun, 27 Nov 2016 15:18:05 +0200
Message-ID: <CALzJLG_ASzRACEtuzd2GazLq1U9edcC11CPZijFZdmSyJG1F_w@mail.gmail.com>
References: <1480169914-22347-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35694 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750833AbcK0NS2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 08:18:28 -0500
Received: by mail-lf0-f66.google.com with SMTP id p100so6984906lfg.2
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 05:18:27 -0800 (PST)
In-Reply-To: <1480169914-22347-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 26, 2016 at 4:18 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> Hi Dave,
>
> This series provides the following mlx5 updates:
>
> From Huy:
> DCBX CEE API and DCBX firmware/host modes support.
>     - 1st patch ensures the dcbnl_rtnl_ops is published only when the qos
>       capability bits is on.
>     - 2nd patch adds the support for CEE interfaces into mlx5 dcbnl_rtnl_ops
>     - 3rd patch refactors ETS query to read ETS configuration directly from
>       firmware rather than having a software shadow to it. The existing IEEE
>       interfaces stays the same.
>     - 4th patch adds the support for MLX5_REG_DCBX_PARAM and MLX5_REG_DCBX_APP
>       firmware commands to manipulate mlx5 DCBX mode.
>     - 5th patch adds the driver support for the new DCBX firmware.  This ensures
>       the backward compatibility versus the old and new firmware. With the new DCBX
>       firmware, qos settings can be controlled by either firmware or software
>       depending on the DCBX mode.
>
> From Kamal and Saeed:
>     - mlx5 self-test support.
>
> From Shaker:
>     - Private flag to give the user the ability to enable/disable mlx5 CQE
>       compression.
>

Hi Dave,

Please hold on with this series, we need a respin to fix some static
checkers warnings.

Thanks
Saeed.
