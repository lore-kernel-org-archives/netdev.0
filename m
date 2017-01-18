From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next v2] net/mlx5e: Support bpf_xdp_adjust_head()
Date: Wed, 18 Jan 2017 13:45:07 +0200
Message-ID: <CALzJLG_F0RYWRcAra_oqVNbH8jMJLf_octxxdA2jJyDMMbgzOg@mail.gmail.com>
References: <1484719567-2774431-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:33806 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752482AbdARLp2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 06:45:28 -0500
Received: by mail-qt0-f194.google.com with SMTP id a29so1229542qtb.1
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 03:45:28 -0800 (PST)
In-Reply-To: <1484719567-2774431-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2017 at 8:06 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> This patch adds bpf_xdp_adjust_head() support to mlx5e.
>
> 1. rx_headroom is added to struct mlx5e_rq.  It uses
>    an existing 4 byte hole in the struct.
> 2. The adjusted data length is checked against
>    MLX5E_XDP_MIN_INLINE and MLX5E_SW2HW_MTU(rq->netdev->mtu).
> 3. The macro MLX5E_SW2HW_MTU is moved from en_main.c to en.h.
>    MLX5E_HW2SW_MTU is also moved to en.h for symmetric reason
>    but it is not a must.
>
> v2:
> - Keep the xdp specific logic in mlx5e_xdp_handle()
> - Update dma_len after the sanity checks in mlx5e_xmit_xdp_frame()
>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Acked-by: Saeed Mahameed <saeedm@mellanox.com>


Thank you Martin.
